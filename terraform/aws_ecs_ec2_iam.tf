# ##############################
# ECS EC2 IAM
# ##############################

# EC2 Assume role
resource "aws_iam_role" "ecs_ec2_role" {
  name               = "${var.app_name}-ecs-ec2-role"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  EOF
}

# EC2 Assume role policy
resource "aws_iam_role_policy" "ecs_ec2_role_policy" {
  name   = "${var.app_name}-ecs-ec2-role-policy"
  role   = aws_iam_role.ecs_ec2_role.id
  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:Submit*",
                "ecs:StartTask",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "logs:DescribeLogStreams"
              ],
              "Resource": [
                  "arn:aws:logs:*:*:*"
              ]
          }
      ]
  }
  EOF

}

# instance profile
resource "aws_iam_instance_profile" "ecs_ec2_profile" {
  name = "${var.app_name}-ecs_ec2_profile"
  role = aws_iam_role.ecs_ec2_role.name
}
