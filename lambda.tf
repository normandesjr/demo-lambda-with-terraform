resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda_sqs_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "lambda_cloudwatch_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "sqs_notification_function" {
  filename         = "./lambda/lambda_function.zip"
  description      = "Send to SQS a message using cron from CloudWatch"
  function_name    = "send-message-to-sqs"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "handler.sendNotificationToSQS"
  source_code_hash = "${base64sha256(file("./lambda/lambda_function.zip"))}"
  runtime          = "nodejs8.10"
  publish          = "true"
  environment {
    variables {
      region = "${var.region}",
      sqsUrl = "${aws_sqs_queue.first_queue.id}"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.sqs_notification_function.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.event.arn}"
}


resource "aws_lambda_alias" "sqs_notification_function_alias" {
  name             = "prod"
  description      = "Lambda que envia mensagem para o SQS"
  function_name    = "${aws_lambda_function.sqs_notification_function.arn}"
  function_version = "${aws_lambda_function.sqs_notification_function.version}"
}
