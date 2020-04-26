provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/aws/ecs/fargate/fargate.tf"
    region = "ap-northeast-1"
  }
}

resource "aws_ecs_cluster" "sample" {
  name = var.cluster-name
}

resource "aws_cloudwatch_log_group" "sample" {
  name = "/ecs/sample"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_policy" "get_secrets" {
  name = "${var.cluster-name}-get-secrets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_secrets" {
  role       = data.aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.get_secrets.arn
}

# Service

locals {
  service_task_definitions_vars = {
    log-group = aws_cloudwatch_log_group.sample.name
    param1    = aws_ssm_parameter.param1.arn
    param2    = aws_ssm_parameter.param2.arn
    param3    = aws_secretsmanager_secret_version.param3.arn
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  container_definitions    = templatefile("task-definitions/service.json", local.service_task_definitions_vars)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ssm_parameter" "param1" {
  name  = "param1"
  type  = "String"
  value = "value1"
}

resource "aws_ssm_parameter" "param2" {
  name  = "param2"
  type  = "SecureString"
  value = "value2"
}

resource "aws_secretsmanager_secret" "param3" {
  name = "param3"
}

resource "aws_secretsmanager_secret_version" "param3" {
  secret_id     = aws_secretsmanager_secret.param3.id
  secret_string = "value3"
}

resource "aws_ecs_service" "sample" {
  name            = "sample"
  cluster         = aws_ecs_cluster.sample.id
  task_definition = aws_ecs_task_definition.service.arn
  launch_type     = "FARGATE"
  desired_count   = 3
  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.sample.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.http.arn
    container_name   = "nginx"
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_security_group" "sample" {
  vpc_id = aws_vpc.demo.id
  name   = "sample"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  tags = {
    Name = "sample"
  }
}

resource "aws_lb" "alb" {
  name               = var.cluster-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sample.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  name        = "${var.cluster-name}-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.demo.id
  target_type = "ip"
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 6
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.sample.name}/${aws_ecs_service.sample.name}"
  role_arn           = data.aws_iam_role.aws_service_role_for_application_autoScaling_ecs_service.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

data "aws_iam_role" "aws_service_role_for_application_autoScaling_ecs_service" {
  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${var.cluster-name}-appas-ECSServiceAverageCPUUtilization"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 75
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

output "url" {
  value = aws_lb.alb.dns_name
}

# Scheduled task

locals {
  scheduled_task_task_definitions_vars = {
    log-group = aws_cloudwatch_log_group.sample.name
  }
}

resource "aws_ecs_task_definition" "scheduled_task" {
  family                   = "scheduled_task"
  container_definitions    = templatefile("task-definitions/scheduled_task.json", local.scheduled_task_task_definitions_vars)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_scheduled_task" {
  name               = "${var.cluster-name}-ecs-scheduled-task"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_scheduled_task" {
  name   = "${var.cluster-name}-ecs-scheduled-task"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "iam:PassRole",
          "ecs:RunTask"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_scheduled_task" {
  role       = aws_iam_role.ecs_scheduled_task.name
  policy_arn = aws_iam_policy.ecs_scheduled_task.arn
}

resource "aws_cloudwatch_event_rule" "ecs_scheduled_task" {
  name                = "ecs-scheduled-task"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "${var.cluster-name}-ecs-scheduled-task"
  arn       = aws_ecs_cluster.sample.arn
  rule      = aws_cloudwatch_event_rule.ecs_scheduled_task.name
  role_arn  = aws_iam_role.ecs_scheduled_task.arn
  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.scheduled_task.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [for subnet in aws_subnet.private : subnet.id]
      security_groups  = [aws_security_group.sample.id]
      assign_public_ip = false
    }
  }
}
