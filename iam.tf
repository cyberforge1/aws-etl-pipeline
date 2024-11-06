# 'iam.tf'

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

# Attach AWSLambdaBasicExecutionRole Policy for CloudWatch Logging
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom IAM Policy for S3 Access
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda-s3-policy"
  description = "Custom policy for Lambda S3 access"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::etl-raw-zone-bucket",
          "arn:aws:s3:::etl-raw-zone-bucket/*",
          "arn:aws:s3:::etl-processed-zone-bucket",
          "arn:aws:s3:::etl-processed-zone-bucket/*"
        ]
      }
    ]
  })
}

# Attach Custom S3 Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

# Custom IAM Policy for SNS Publish
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "lambda-sns-policy"
  description = "Custom policy for Lambda to publish to SNS"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": "${aws_sns_topic.lambda_notification.arn}"
      }
    ]
  })
}

# Attach the SNS Policy to the Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# Custom IAM Policy for Glue Crawler Start for Lambda
resource "aws_iam_policy" "lambda_glue_policy" {
  name        = "lambda-glue-policy"
  description = "Custom policy for Lambda to start the Glue Crawler"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "glue:StartCrawler",
        "Resource": "arn:aws:glue:${var.CUSTOM_AWS_REGION}:${var.aws_account_id}:crawler/etl-crawler"  # Ensure 'etl-crawler' matches your actual crawler name
      }
    ]
  })
}

# Attach the Glue Policy to the Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_glue_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_policy.arn
}

# IAM Role for Glue Crawler
resource "aws_iam_role" "glue_role" {
  name = "glue-service-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach S3 access policy for Glue Crawler
resource "aws_iam_role_policy_attachment" "glue_s3_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach Glue Service Policy to Glue Crawler Role
resource "aws_iam_role_policy_attachment" "glue_service_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
