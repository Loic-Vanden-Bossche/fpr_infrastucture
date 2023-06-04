resource "aws_ecs_cluster" "fpr_backend_cluster" {
  name = "fpr-backend-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fpr_backend_capacity_providers" {
  cluster_name       = aws_ecs_cluster.fpr_backend_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
    base              = 0
  }
}

resource "aws_ecs_task_definition" "fpr_backend_task" {
  family = "fpr-backend-task"

  container_definitions = jsonencode([
    {
      name : "fpr-backend-task",
      image : "${var.docker_hub_username}/${var.docker_hub_image_name}:${var.docker_hub_image_tag}",
      repositoryCredentials : {
        "credentialsParameter" : aws_secretsmanager_secret.fpr_backend_docker_access_key.arn
      },
      essential : true,
      portMappings : [
        {
          "containerPort" : 8080,
          "hostPort" : 8080
        }
      ],
      healthCheck : {
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost:8080/actuator/health || exit 1"
        ],
        interval : 10,
        timeout : 5,
        retries : 10,
        startPeriod : 240
      },
      environment : [
        {
          name : "spring.datasource.url",
          value : "jdbc:postgresql://${aws_db_instance.fpr_backend_db.address}:${aws_db_instance.fpr_backend_db.port}/${aws_db_instance.fpr_backend_db.db_name}"
        },
        {
          name : "spring.datasource.usename",
          value : var.rds_pg_username
        },
        {
          name : "spring.datasource.password",
          value : var.rds_pg_password
        },
        {
          name : "spring.profiles.active",
          value : "prod"
        }
      ],
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-create-group : "true",
          awslogs-group : "awslogs-backend",
          awslogs-region : var.region,
          awslogs-stream-prefix : "awslogs-backend"
        }
      },
      memoryReservation : 1024,
      cpuReservation : 256
    }
  ])
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_launch_template" "ecs_launch_template" {
  name          = "fpr-backend-launch-template"
  image_id      = "ami-08df359630daf99c7"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "ecs_asg" {
  name = "fpr-backend-asg"

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "fpr-backend-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
  }
}

resource "aws_ecs_service" "fpr_backend_service" {
  #  lifecycle {
  #    create_before_destroy = true
  #    ignore_changes        = [task_definition]
  #  }

  name            = "fpr-backend-service"
  cluster         = aws_ecs_cluster.fpr_backend_cluster.id
  task_definition = aws_ecs_task_definition.fpr_backend_task.arn

  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.fpr_backend_task.family
    container_port   = 8080
  }

  network_configuration {
    subnets         = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    security_groups = [aws_security_group.service_security_group.id]
  }
}