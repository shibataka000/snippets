resource "aws_secretsmanager_secret" "main" {
  name       = "sample"
  kms_key_id = aws_kms_key.main.arn
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id = aws_secretsmanager_secret.main.id
  secret_string = jsonencode({
    JIRA_USERNAME = "user@example.com"
    JIRA_PASSWORD = "JIRA_API_TOKEN"
  })
}
