# COMMANDS


## VENV

source venv/bin/activate

pip freeze > requirements.txt

pip install -r requirements.txt


## Terraform

terraform plan

export AWS_REGION="ap-southeast-2"

terraform apply

terraform destroy


## Document Upload

python scripts/upload_new_document.py

python scripts/upload_to_processed_bucket.py


## AWS

aws configure

aws s3 ls s3://etl-raw-zone-bucket/


## Zip Lambda functions


cd lambda_package

zip -r ../lambda_package.zip .



cd new_lambda_package

zip -r ../start_glue_etl_job_lambda.zip .



## Basic Checks

### Check S3 Bucket Content
aws s3 ls s3://etl-raw-zone-bucket

### Test Lambda and First SNS
aws lambda invoke \
  --function-name etl-s3-ingest \
  response.json





### Must confirm subscription and add AWS_ACCOUNT_ID as an environmental variable in the console for successful lambda function execution and SNS message