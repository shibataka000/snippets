resource "aws_cloudformation_stack" "github" {
  name         = "github-inbound-webhook-stack"
  template_url = "https://eventbridge-inbound-webhook-templates-prod-us-east-1.s3.us-east-1.amazonaws.com/cfn-templates/github/template.yaml"
  parameters = {
    "GithubWebhookSecret"       = "github-inbound-webhook-secret"
    "EventBusName"              = aws_cloudwatch_event_bus.github.name
    "LambdaInvocationThreshold" = 2000
  }
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
    "CAPABILITY_AUTO_EXPAND",
  ]
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}
