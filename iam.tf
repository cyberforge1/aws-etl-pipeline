# 'iam.tf'

# IAM Role for Lambda functions (shared by both s3_ingest_lambda and start_glue_etl_job_lambda)
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

# Custom IAM Policy for S3 Access (used by both Lambda functions)
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

# Custom IAM Policy for SNS Publish (if needed for notifications)
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "lambda-sns-policy"
  description = "Custom policy for Lambda to publish to SNS"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": aws_sns_topic.lambda_notification.arn
      }
    ]
  })
}

# Attach the SNS Policy to the Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# Custom IAM Policy for Glue Job Start and Get for Lambda
resource "aws_iam_policy" "lambda_glue_policy" {
  name        = "lambda-glue-policy"
  description = "Custom policy for Lambda to start and get Glue jobs and interact with Glue Crawlers"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetCrawler",
          "glue:StartCrawler"
        ],
        "Resource": [
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:job/etl-job",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:crawler/etl-crawler"
        ]
      }
    ]
  })
}

# Attach the Glue Policy to the Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_glue_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_policy.arn
}

# Add permissions for notify_glue_job_completion_lambda to access S3 and SNS
resource "aws_iam_policy" "lambda_glue_job_completion_policy" {
  name        = "lambda-glue-job-completion-policy"
  description = "Policy for Lambda to list objects in the processed bucket and send SNS notifications"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": "${aws_s3_bucket.processed_zone.arn}"
      },
      {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": aws_sns_topic.lambda_notification.arn
      }
    ]
  })
}

# Attach policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_glue_job_completion_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_job_completion_policy.arn
}

# IAM Role for Glue Crawler and Glue Job
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

# Custom IAM Policy for Glue S3 Access (read and write)
resource "aws_iam_policy" "glue_s3_policy" {
  name        = "glue-s3-access-policy"
  description = "Custom policy for Glue to access S3"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      # Grant access to Raw and Processed buckets
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
      },
      # Grant access to Glue Scripts bucket
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::etl-glue-scripts-bucket",
          "arn:aws:s3:::etl-glue-scripts-bucket/*"
        ]
      }
    ]
  })
}

# Attach Custom S3 Access Policy to Glue Role
resource "aws_iam_role_policy_attachment" "glue_s3_policy_attachment_custom" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

# Attach Glue Service Policy to Glue Role
resource "aws_iam_role_policy_attachment" "glue_service_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
