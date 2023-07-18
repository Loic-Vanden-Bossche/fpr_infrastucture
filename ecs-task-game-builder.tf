resource "aws_ecs_task_definition" "fpr_games_builder_task" {
  family = "fpr-games-builder-task"

  container_definitions = jsonencode([
    {
      name : "fpr-games-builder",
      image : "default-image",
      essential : true,
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-create-group : "true",
          awslogs-group : "awslogs-game",
          awslogs-region : var.region,
          awslogs-stream-prefix : "awslogs-game"
        }
      },
      memory : 512,
      cpu : 256
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_fpr_games_builder_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_fpr_games_builder_task_execution_role.arn
}
