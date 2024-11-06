Basic AWS CLI Checks

1) Check S3 Bucket Content

aws s3 ls s3://etl-raw-zone-bucket

aws s3 ls s3://etl-processed-zone-bucket


2) Test Lambda Function

aws lambda invoke \
  --function-name etl-s3-ingest \
  response.json

aws logs describe-log-streams \
  --log-group-name "/aws/lambda/etl-s3-ingest" \
  --order-by "LastEventTime" \
  --descending

3) Verify SNS Topic Subscription

aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:REGION:ACCOUNT_ID:lambda-completion-topic

4) Check Glue Crawler Status

aws glue get-crawler --name etl-crawler


To start the crawler manually (if needed):

aws glue start-crawler --name etl-crawler

5) Verify Glue Job Runs

aws glue get-job-runs --job-name etl-job

6) Describe EventBridge Rule

aws events describe-rule \
  --name trigger-start-glue-etl-job-lambda

7) Inspect IAM Role Policies

aws iam list-attached-role-policies \
  --role-name glue-service-role

8) View CloudWatch Logs for Lambda

aws logs describe-log-streams \
  --log-group-name "/aws/lambda/start-glue-etl-job" \
  --order-by "LastEventTime" \
  --descending
