resource "aws_codedeploy_app" "example" {
  # name             = "sample-app"
  name             = "ecs"
  compute_platform = "ECS"
}

resource "aws_iam_role" "example" {
  name = "codedeploy-example-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.example.name
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.example.name
  deployment_group_name = "example-group"
  service_role_arn      = aws_iam_role.example.arn

  ecs_service {
    cluster_name = aws_ecs_cluster.sample.name
    service_name = aws_ecs_service.service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }

      target_group {
        name = aws_lb_target_group.http_blue.name
      }

      target_group {
        name = aws_lb_target_group.http_green.name
      }
    }
  }

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_s3_bucket" "appspec" {
  bucket_prefix = "codedeploy-appspec-"
  force_destroy = true
}

resource "aws_s3_bucket_object" "appspec" {
  bucket = aws_s3_bucket.appspec.bucket
  key    = "${aws_ecs_task_definition.service.family}-${aws_ecs_task_definition.service.revision}.yaml"
  content = templatefile("files/appspec.yaml", {
    task_definition_arn = aws_ecs_task_definition.service.arn
    container_name      = "nginx"
    container_port      = 80
  })
}

resource "null_resource" "deploy" {
  triggers = {
    appspec = aws_s3_bucket_object.appspec.etag
  }

  provisioner "local-exec" {
    command = "aws deploy create-deployment --application-name '${aws_codedeploy_app.example.name}' --deployment-group-name '${aws_codedeploy_deployment_group.example.deployment_group_name}' --revision 'revisionType=S3,s3Location={bucket=${aws_s3_bucket.appspec.bucket},key=${aws_s3_bucket_object.appspec.key},bundleType=YAML'}"
  }
}
