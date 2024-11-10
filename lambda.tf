# 'lambda.tf'

# Existing Lambda function for S3 ingestion
resource "aws_lambda_function" "s3_ingest_lambda" {
  function_name = "etl-s3-ingest"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"  # This should match the file and function name
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_package.zip"  # Path to the zip file
}

# Allow S3 to invoke the existing Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_ingest_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_zone.arn  # Ensure it’s the correct bucket ARN
}

# New Lambda function to start Glue ETL job
resource "aws_lambda_function" "start_glue_etl_job_lambda" {
  function_name = "start-glue-etl-job"
  role          = aws_iam_role.lambda_role.arn
  handler       = "start_glue_etl_job_lambda.start_glue_etl_job_lambda"  # Updated handler name
  runtime       = "python3.9"
  filename      = "${path.module}/start_glue_etl_job_lambda.zip"  # Path to the new zip file
  environment {
    variables = {
      GLUE_JOB_NAME = "etl-job"  # Ensure GLUE_JOB_NAME is set correctly
    }
  }
}

# Lambda function to notify on Glue Job completion
resource "aws_lambda_function" "notify_glue_job_completion_lambda" {
  function_name = "notify-glue-job-completion"
  role          = aws_iam_role.lambda_role.arn
  handler       = "notify_glue_job_completion.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/notify_glue_job_completion_lambda.zip"
  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_zone.bucket
      SNS_TOPIC_ARN    = aws_sns_topic.lambda_notification.arn
    }
  }
}