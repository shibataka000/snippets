resource "aws_sfn_state_machine" "my_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.sfn_my_state_machine.arn
  definition = templatefile("./sfn_state_machine_definition.json", {
    connection_arn = aws_cloudwatch_event_connection.zipcloud.arn
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn_my_state_machine.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}
