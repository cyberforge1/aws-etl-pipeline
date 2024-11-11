# COMMANDS


## VENV

source venv/bin/activate

pip freeze > requirements.txt

pip install -r requirements.txt


## Terraform

cd terraform

terraform plan

terraform apply

terraform destroy


## Document Upload

python scripts/upload_new_document.py

python scripts/upload_to_processed_bucket.py

*** update script in s3 bucket : aws s3 cp scripts/scripts/scripts/scripts/scripts/glue_etl_script s3://etl-glue-scripts-bucket/glue_etl_script


## AWS

aws configure

aws s3 ls s3://etl-raw-zone-bucket/


## Zip Lambda functions


cd lambda_functions/lambda_package
zip -r ../../zipped_lambda_functions/lambda_package.zip .
cd ../..


cd lambda_functions/new_lambda_package
zip -r ../../zipped_lambda_functions/start_glue_etl_job_lambda.zip .
cd ../..


cd lambda_functions/glue_job_completion
zip -r ../../zipped_lambda_functions/notify_glue_job_completion_lambda.zip notify_glue_job_completion.py
cd ../..



## Basic Checks

### Check S3 Bucket Content
aws s3 ls s3://etl-raw-zone-bucket

### Test Lambda and First SNS
aws lambda invoke \
  --function-name etl-s3-ingest \
  response.json





### Must confirm subscription and add AWS_ACCOUNT_ID as an environmental variable in the console for successful lambda function execution and SNS message