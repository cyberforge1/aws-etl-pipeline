# 'terraform/eventbridge.tf'

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

resource "aws_cloudwatch_event_target" "trigger_start_glue_etl_job_lambda" {
  rule = aws_cloudwatch_event_rule.trigger_start_glue_etl_job_lambda_rule.name
  arn  = aws_lambda_function.start_glue_etl_job_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_invoke_start_glue_etl_job" {
  statement_id  = "AllowEventBridgeInvokeStartGlueETLJob"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_glue_etl_job_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_start_glue_etl_job_lambda_rule.arn
}

resource "aws_cloudwatch_event_rule" "trigger_glue_job_completion" {
  name        = "trigger-glue-job-completion"
  description = "Triggers Lambda on Glue Job Succeeded event"

  event_pattern = jsonencode({
    "source": ["aws.glue"],
    "detail-type": ["Glue Job State Change"],
    "detail": {
      "jobName": ["etl-job"],
      "state": ["SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "glue_job_completion_target" {
  rule = aws_cloudwatch_event_rule.trigger_glue_job_completion.name
  arn  = aws_lambda_function.notify_glue_job_completion_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_invoke_notify_glue_job_completion" {
  statement_id  = "AllowEventBridgeInvokeNotifyGlueJobCompletion"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_glue_job_completion_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_glue_job_completion.arn
}
