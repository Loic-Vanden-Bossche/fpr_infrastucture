resource "aws_ecs_task_definition" "fpr_game_task" {
  family = "fpr-game-task"

  container_definitions = jsonencode([
    {
      name : "fpr-game-default-task",
      image : "default-image",
      essential : true,
      portMappings : [
        {
          "containerPort" : 8070,
          "hostPort" : 8070
        }
      ],
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
  execution_role_arn       = aws_iam_role.ecs_fpr_backend_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_fpr_backend_task_execution_role.arn
}
