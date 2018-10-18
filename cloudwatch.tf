resource "aws_cloudwatch_event_rule" "event" {
  name        = "cron-schedule"

  schedule_expression = "cron(0 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "event_to_lambda" {
  rule = "${aws_cloudwatch_event_rule.event.name}"
  target_id = "sqs_notification_function"
  arn = "${aws_lambda_function.sqs_notification_function.arn}"
}
