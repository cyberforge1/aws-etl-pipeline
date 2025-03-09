# 'terraform/sns.tf'

resource "aws_sns_topic" "lambda_notification" {
  name = "lambda-completion-topic"
}

resource "aws_sns_topic_subscription" "lambda_email_subscription" {
  topic_arn = aws_sns_topic.lambda_notification.arn
  protocol  = "email"
  endpoint  = "cyberforge1@gmail.com"
}
