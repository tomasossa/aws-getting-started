provider "aws" {
  region = var.aws_region
}

resource "random_pet" "container" {}

resource "aws_ecr_repository" "repo" {
  name = "tf-aws-getting-started"

  provisioner "local-exec" {
    command     = <<-EOT
      aws ecr get-login-password | docker login --username AWS --password-stdin ${self.repository_url}
      docker build -t tf-aws-getting-started .
      docker tag tf-aws-getting-started:latest ${self.repository_url}:latest
      docker push ${self.repository_url}:latest
    EOT
    working_dir = "../"
  }
}

resource "aws_ecs_cluster" "default" {
  name = "default-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.task_definition_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.task_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::029011216774:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = random_pet.container.id
      image     = aws_ecr_repository.repo.repository_url
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-stream-prefix = "ecs"
          awslogs-region        = var.aws_region
        }
      }
    }
  ])
}
