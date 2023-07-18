resource "aws_ecs_cluster" "fpr_backend_cluster" {
  name = "fpr-backend-cluster"
}

resource "aws_ecs_service" "fpr_backend_service" {
  name            = "fpr-backend-service"
  cluster         = aws_ecs_cluster.fpr_backend_cluster.id
  task_definition = aws_ecs_task_definition.fpr_backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.fpr_backend_task.family
    container_port   = 8080
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.backend_security_group.id]
  }
}