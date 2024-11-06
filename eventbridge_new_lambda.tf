# EventBridge rule to trigger the new Lambda function
resource "aws_cloudwatch_event_rule" "trigger_hello_world_lambda_rule" {
  name        = "trigger-hello-world-lambda"
  description = "Trigger hello-world-lambda on specific events"

  event_pattern = jsonencode({
    "source": ["aws.glue"],
    "detail-type": ["Glue Crawler State Change"],
    "detail": {
      "state": ["SUCCEEDED"]
    }
  })
}

# Target to call the new Lambda function
resource "aws_cloudwatch_event_target" "trigger_hello_world_lambda" {
  rule = aws_cloudwatch_event_rule.trigger_hello_world_lambda_rule.name
  arn  = aws_lambda_function.hello_world_lambda.arn
}

# Allow EventBridge to invoke the new Lambda function
resource "aws_lambda_permission" "allow_eventbridge_invoke_hello_world" {
  statement_id  = "AllowEventBridgeInvokeHelloWorld"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_lambda.function_name
  principal     = "events.amazonaws.com"
}
