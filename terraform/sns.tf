# 'terraform/sns.tf'

# Define an SNS Topic for Lambda completion notifications
resource "aws_sns_topic" "lambda_notification" {
  name = "lambda-completion-topic"
}

# Define an SNS Subscription to send an email notification to cyberforge1@gmail.com
resource "aws_sns_topic_subscription" "lambda_email_subscription" {
  topic_arn = aws_sns_topic.lambda_notification.arn
  protocol  = "email"
  endpoint  = "cyberforge1@gmail.com"
}
