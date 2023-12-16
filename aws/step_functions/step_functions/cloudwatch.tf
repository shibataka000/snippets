resource "aws_cloudwatch_log_group" "sfn_my_state_machine" {
  name = "sfn-my-state-machine"
}

resource "aws_cloudwatch_event_connection" "zipcloud" {
  name               = "zipcloud"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "api_key"
      value = "value"
    }
  }
}
