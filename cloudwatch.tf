resource "aws_cloudwatch_event_rule" "event" {
  name        = "cron-schedule"
  schedule_expression = "cron(0 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "event_to_lambda" {
  rule = "${aws_cloudwatch_event_rule.event.name}"
  arn = "${aws_lambda_alias.sqs_notification_function_alias.arn}"
  input = "{\"job\":\"myJobName\"}"
}
