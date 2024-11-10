# lambda_functions/glue_job_completion/notify_glue_job_completion.py

import boto3
import os
import json

s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    """Triggered by Glue job completion to send notification with list of processed files."""
    print("Lambda invoked by Glue Job completion event.")

    # Processed bucket name and SNS topic ARN from environment variables
    processed_bucket = os.environ['PROCESSED_BUCKET']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    try:
        # List objects in the processed bucket
        response = s3_client.list_objects_v2(Bucket=processed_bucket)
        if 'Contents' not in response:
            print("No files found in processed bucket.")
            return {'statusCode': 200, 'body': 'No files to report in processed bucket.'}

        # Extract file names
        file_names = [obj['Key'] for obj in response['Contents']]
        file_list = "\n".join(file_names)

        # Prepare new message specifically for processed bucket notifications
        message = {
            'default': 'Glue job has finished running and written a document to the processed S3 bucket.',
            'email': (
                f"Hello,\n\n"
                f"The Glue job has completed successfully, and the following document(s) have been "
                f"written to the processed S3 bucket ({processed_bucket}):\n\n"
                f"{file_list}\n\n"
                "This indicates that the data processing step has completed.\n\n"
                "Regards,\nYour ETL Notification System"
            )
        }

        # Publish message to SNS
        sns_response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message),
            Subject='Glue Job Completion Notification - Document Written to Processed Bucket',
            MessageStructure='json'
        )
        print("SNS Publish Response:", sns_response)
        return {'statusCode': 200, 'body': 'Notification sent successfully'}

    except Exception as e:
        print(f"Error listing files or publishing to SNS: {e}")
        return {'statusCode': 500, 'body': f'Error: {str(e)}'}
