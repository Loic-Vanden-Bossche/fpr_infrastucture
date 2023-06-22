resource "aws_iam_role" "ecs_fpr_backend_task_execution_role" {
  name               = "ecs-fpr-backend-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "ecs_fpr_games_builder_task_execution_role" {
  name               = "ecs-fpr-games-builder-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_fpr_backend_task_execution_role_policy" {
  role       = aws_iam_role.ecs_fpr_backend_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_fpr_games_builder_task_execution_role_policy" {
  role       = aws_iam_role.ecs_fpr_games_builder_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "logs_policy" {
  name = "logs_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource : [
          "arn:aws:logs:*:*:*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_get_image_policy" {
  name = "ecr-get-image-policy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_fpr_backend_task_execution_ssm_role_policy" {
  name = "ecs_task_execution_role_policy"
  role = aws_iam_role.ecs_fpr_backend_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          aws_secretsmanager_secret.fpr_backend_docker_access_key.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_fpr_backend_task_execution_ecr_role_policy" {
  name = "ecs-fpr-backend-task-execution-ecr-role-policy"
  role = aws_iam_role.ecs_fpr_backend_task_execution_role.id

  policy = aws_iam_policy.ecr_get_image_policy.policy
}

resource "aws_iam_role_policy" "ecs_fpr_backend_task_execution_logs_role_policy" {
  name = "ecs-fpr-backend-task-execution-logs-role-policy"
  role = aws_iam_role.ecs_fpr_backend_task_execution_role.id

  policy = aws_iam_policy.logs_policy.policy
}

resource "aws_iam_role_policy" "ecs_fpr_games_builder_task_execution_logs_role_policy" {
  name = "ecs-fpr-backend-task-execution-logs-role-policy"
  role = aws_iam_role.ecs_fpr_games_builder_task_execution_role.id

  policy = aws_iam_policy.logs_policy.policy
}

resource "aws_iam_role_policy" "ecs_fpr_backend_task_execution_role_policy" {
  name = "ecs-fpr-backend-task-execution-role-policy"
  role = aws_iam_role.ecs_fpr_backend_task_execution_role.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "iam:PassRole",
          "ec2:DescribeSecurityGroups",
          "ecs:ListClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:RunTask",
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_fpr_games_builder_task_execution_role_policy" {
  name = "ecs-fpr-games-builder-task-execution-role-policy"
  role = aws_iam_role.ecs_fpr_games_builder_task_execution_role.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "iam:PassRole",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetObject",
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_user" "ecr_user" {
  name = "ECR-User"
}

resource "aws_iam_user_policy" "ecr_user_policy" {
  name = "ecr-user-policy"
  user = aws_iam_user.ecr_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ECRAccess",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        "Resource" : "*"
      }
    ]
  })
}