resource "aws_sqs_queue" "first_queue" {
  name                       = "my-queue"
  visibility_timeout_seconds = 30
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 5
  delay_seconds              = 0
}

data "aws_iam_policy_document" "sqs_queue_policy_document" {
  statement {
    sid = "SQSQueuesPolicy"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:*"
    ]

    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "first_queue_policy" {
  queue_url = "${aws_sqs_queue.first_queue.id}"
  policy    = "${data.aws_iam_policy_document.sqs_queue_policy_document.json}"
}
