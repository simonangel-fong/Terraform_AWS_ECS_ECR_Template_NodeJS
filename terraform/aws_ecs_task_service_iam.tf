# ##############################
# ECS IAM
# ##############################

# ECS Assume role
resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.app_name}-ecs-service-role"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ecs.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  EOF

}

# attach policy
resource "aws_iam_policy_attachment" "ecs_service_policy_attach" {
  name       = "${var.app_name}-ecs-service-policy-attach"
  roles      = [aws_iam_role.ecs_service_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
