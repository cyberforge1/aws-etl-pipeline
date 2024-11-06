# 'eventbridge.tf'

# EventBridge rule to trigger the Lambda function for starting the Glue ETL job
resource "aws_cloudwatch_event_rule" "trigger_start_glue_etl_job_lambda_rule" {
  name        = "trigger-start-glue-etl-job-lambda"
  description = "Trigger start-glue-etl-job-lambda on Glue Crawler Succeeded event"

  event_pattern = jsonencode({
    "source": ["aws.glue"],
    "detail-type": ["Glue Crawler State Change"],
    "detail": {
      "crawlerName": ["etl-crawler"],
      "state": ["Succeeded"]
    }
  })
}

# Target to call the start_glue_etl_job_lambda function
resource "aws_cloudwatch_event_target" "trigger_start_glue_etl_job_lambda" {
  rule = aws_cloudwatch_event_rule.trigger_start_glue_etl_job_lambda_rule.name
  arn  = aws_lambda_function.start_glue_etl_job_lambda.arn
}

# Allow EventBridge to invoke the start_glue_etl_job_lambda function
resource "aws_lambda_permission" "allow_eventbridge_invoke_start_glue_etl_job" {
  statement_id  = "AllowEventBridgeInvokeStartGlueETLJob"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_glue_etl_job_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_start_glue_etl_job_lambda_rule.arn
}
