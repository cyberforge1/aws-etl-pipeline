# 'lambda.tf'

resource "aws_lambda_function" "s3_ingest_lambda" {
  function_name = "etl-s3-ingest"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_package.zip"  # Ensures Terraform finds the file
}
