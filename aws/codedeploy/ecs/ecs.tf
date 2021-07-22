resource "aws_ecs_cluster" "sample" {
  name = var.cluster-name
}

resource "aws_cloudwatch_log_group" "sample" {
  name = "/ecs/${var.cluster-name}"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster-name}-ecs-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_security_group" "sample" {
  vpc_id = aws_vpc.demo.id
  name   = var.cluster-name

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
    Name = "${var.cluster-name}"
  }
}

# Service

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.cluster-name}-service"
  container_definitions    = templatefile("task-definitions/service.json", { log-group = aws_cloudwatch_log_group.sample.name })
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "service" {
  name            = "${var.cluster-name}-service"
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
    target_group_arn = aws_lb_target_group.http_blue.arn
    container_name   = "nginx"
    container_port   = 80
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      load_balancer
    ]
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
    target_group_arn = aws_lb_target_group.http_blue.arn
  }

  lifecycle {
    ignore_changes = [
      default_action[0].target_group_arn
    ]
  }
}

resource "aws_lb_target_group" "http_blue" {
  name        = "${var.cluster-name}-http-blue"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.demo.id
  target_type = "ip"
}

resource "aws_lb_target_group" "http_green" {
  name        = "${var.cluster-name}-http-green"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.demo.id
  target_type = "ip"
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 6
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.sample.name}/${aws_ecs_service.service.name}"
  role_arn           = data.aws_iam_role.ecs_service_role_for_application_autoscaling.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

data "aws_iam_role" "ecs_service_role_for_application_autoscaling" {
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
