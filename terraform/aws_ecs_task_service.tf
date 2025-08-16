# ##############################
# ECS Task definition
# ##############################
resource "aws_ecs_task_definition" "ecs_task" {
  family = "${var.app_name}-ecs-task"
  container_definitions = templatefile("../ecs/app.json.tpl", {
    REPOSITORY_URL = "${aws_ecr_repository.ecr_repo.repository_url}"
  })

  tags = {
    Name = "${var.app_name}-ecs-task"
  }
}

# ##############################
# ECS service
# ##############################
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.app_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  iam_role        = aws_iam_role.ecs_service_role.arn
  depends_on      = [aws_iam_policy_attachment.ecs_service_policy_attach]

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = var.container_name
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
