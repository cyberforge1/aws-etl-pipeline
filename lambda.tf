# 'lambda.tf'

resource "aws_lambda_function" "s3_ingest_lambda" {
  function_name = "etl-s3-ingest"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"  # This should match the file and function name
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_package.zip"  # Path to the zip file
}

# Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_ingest_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_zone.arn  # Grant access only to this bucket
}
