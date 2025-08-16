# ##############################
# ECS Cluster
# ##############################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}_ecs_cluster"
}

# ##############################
# ECS EC2 launch template
# ##############################
resource "aws_launch_template" "ecs_instance_template" {
  name                   = "${var.app_name}-instance-template"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.ecs_ec2_sg.id}"]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_ec2_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
# mkdir -pv /etc/ecs/
echo "ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name}" >> /etc/ecs/ecs.config
EOF
  )
}

# ec2 sg
resource "aws_security_group" "ecs_ec2_sg" {
  name   = "${var.app_name}-ecs-ec2-sg"
  vpc_id = aws_vpc.app_vpc.id

  # inbound: ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound: http
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-ec2-sg"
  }
}

# ##############################
# ECS autoscaling group
# ##############################
resource "aws_autoscaling_group" "ecs_auto_group" {
  name             = "${var.app_name}-ecs-auto-group"
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.main_subnet_public_a.id
    , aws_subnet.main_subnet_public_b.id
  ]

  launch_template {
    id      = aws_launch_template.ecs_instance_template.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.app_name}-instance"
    propagate_at_launch = true
  }
}

# ##############################
# ECS autoscaling group
# ##############################
resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.main_subnet_public_a.id
    , aws_subnet.main_subnet_public_b.id
  ]
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "${var.app_name}-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
  health_check { path = "/" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}


resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-sg"
  vpc_id      = aws_vpc.app_vpc.id
  description = "security group for ecs"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

# ##############################
# Output
# ##############################
output "alb_url" {
  value = aws_lb.alb.dns_name
}
