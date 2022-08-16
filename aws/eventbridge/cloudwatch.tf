resource "aws_cloudwatch_event_bus" "github" {
  name = "github-inbound-webhook"
}

resource "aws_cloudwatch_event_rule" "github" {
  name           = "github-inbound-webhook"
  event_bus_name = aws_cloudwatch_event_bus.github.name
  event_pattern  = <<EOF
{
  "account": ["370106426606"],
  "source": ["github.com"]
}
EOF
}

resource "aws_cloudwatch_event_target" "cloudwatch_log" {
  target_id      = "github-inbound-webhook"
  event_bus_name = aws_cloudwatch_event_bus.github.name
  rule           = aws_cloudwatch_event_rule.github.name
  arn            = aws_cloudwatch_log_group.github.arn
}

resource "aws_cloudwatch_log_group" "github" {
  name = "github-inbound-webhook"
}

resource "aws_cloudwatch_log_resource_policy" "github" {
  policy_document = data.aws_iam_policy_document.log_policy.json
  policy_name     = "github-inbound-webhook-policy"
}

data "aws_iam_policy_document" "log_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.github.arn}:*"
    ]

    principals {
      identifiers = ["events.amazonaws.com", "delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
