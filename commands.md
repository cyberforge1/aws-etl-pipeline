# COMMANDS


## VENV

source venv/bin/activate

pip freeze > requirements.txt

pip install -r requirements.txt


## Terraform

terraform plan

export $(grep -v '^#' .env | xargs)

terraform apply

terraform destroy


## AWS

aws configure

aws s3 ls s3://etl-raw-zone-bucket/


## Zip

cd lambda_package

zip -r ../lambda_package.zip .

## Basic Checks

### Check S3 Bucket Content
aws s3 ls s3://etl-raw-zone-bucket

### Test Lambda and First SNS
aws lambda invoke \
  --function-name etl-s3-ingest \
  response.json

### Eventbridge Trigger

aws events put-events --entries '[
  {
    "Source": "aws.glue",
    "DetailType": "Glue Crawler State Change",
    "Detail": "{\"state\": \"SUCCEEDED\"}"
  }
]'

### New Lambda Function Trigger

aws lambda invoke \
  --function-name hello-world-lambda \
  --payload '{}' \
  response.json





### Must confirm subscription and add AWS_ACCOUNT_ID as an environmental variable in the console for successful lambda function execution and SNS message