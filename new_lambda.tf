# IAM Role for the new Lambda function
resource "aws_iam_role" "hello_world_lambda_role" {
  name = "hello-world-lambda-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWSLambdaBasicExecutionRole for CloudWatch Logging
resource "aws_iam_role_policy_attachment" "hello_world_lambda_basic_execution" {
  role       = aws_iam_role.hello_world_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define the new Lambda function
resource "aws_lambda_function" "hello_world_lambda" {
  function_name = "hello-world-lambda"
  role          = aws_iam_role.hello_world_lambda_role.arn
  handler       = "hello_world_lambda.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/hello_world_lambda.zip"  # Path to the zip file
  source_code_hash = filebase64sha256("${path.module}/hello_world_lambda.zip")
}
