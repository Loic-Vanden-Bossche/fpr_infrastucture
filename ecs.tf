resource "aws_ecs_cluster" "fpr_backend_cluster" {
  name = "fpr-backend-cluster"
}

resource "aws_ecs_task_definition" "fpr_backend_task" {
  family                   = "fpr-backend-task"
  container_definitions    = jsonencode([
    {
      name : "fpr-backend-task",
      image : "${var.docker_hub_username}/${var.docker_hub_image_name}:${var.docker_hub_image_tag}",
      repositoryCredentials : {
        "credentialsParameter": aws_secretsmanager_secret.fpr_backend_docker_access_key.arn
      },
      essential : true,
      portMappings : [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      healthCheck : {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080/actuator/health || exit 1"
        ],
        interval: 10,
        timeout: 5,
        retries: 10,
        startPeriod: 240
      },
      environment : [
        {
          name: "spring.datasource.url",
          value: "jdbc:postgresql://${aws_db_instance.fpr_backend_db.address}:${aws_db_instance.fpr_backend_db.port}/${aws_db_instance.fpr_backend_db.db_name}"
        },
        {
          name: "spring.datasource.usename",
          value: var.rds_pg_username
        },
        {
          name: "spring.datasource.password",
          value: var.rds_pg_password
        }
      ],
      logConfiguration : {
        logDriver: "awslogs",
        options: {
          awslogs-create-group: "true",
          awslogs-group: "awslogs-backend",
          awslogs-region: var.region,
          awslogs-stream-prefix: "awslogs-backend"
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
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
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
    security_groups  = [aws_security_group.service_security_group.id]
  }
}