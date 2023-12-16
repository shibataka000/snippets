resource "aws_iam_role" "sfn_my_state_machine" {
  name               = "sfn-my-state-machine-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_my_state_machine_assume_role_policy.json
}

data "aws_iam_policy_document" "sfn_my_state_machine_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "sfn_my_state_machine" {
  name   = "sfn-my-state-machine-policy"
  policy = data.aws_iam_policy_document.sfn_my_state_machine_policy.json
}

data "aws_iam_policy_document" "sfn_my_state_machine_policy" {
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "sfn_my_state_machine" {
  role       = aws_iam_role.sfn_my_state_machine.name
  policy_arn = aws_iam_policy.sfn_my_state_machine.arn
}
