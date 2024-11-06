# 'lambda_function.py'

import boto3
import json
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    """Lambda function triggered by S3 events and sends a notification via SNS."""
    print("Lambda function invoked with event:", event)  # Log the S3 event data

    # Check if event contains Records to avoid UnboundLocalError
    if 'Records' in event and event['Records']:
        # Extract bucket and object key from the event
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            print(f"New object created in S3 - Bucket: {bucket_name}, Key: {object_key}")

            # Construct the SNS topic ARN
            account_id = os.getenv('AWS_ACCOUNT_ID')  # Get the account ID from the environment
            topic_arn = f'arn:aws:sns:ap-southeast-2:{account_id}:lambda-completion-topic'

            # Create the message content
            message = {
                'default': 'Lambda function has successfully processed an S3 event.',
                'email': (
                    f"Hello,\n\n"
                    f"A new file has been uploaded to S3 bucket '{bucket_name}' with key '{object_key}'.\n\n"
                    "Regards,\nYour Lambda Notification System"
                )
            }

            # Try to publish a message to the SNS topic and log the result
            try:
                response = sns_client.publish(
                    TopicArn=topic_arn,
                    Message=json.dumps(message),
                    Subject='Lambda S3 Event Notification',
                    MessageStructure='json'
                )
                print("SNS Publish Response:", response)  # Log the SNS publish response
            except Exception as e:
                print("Error publishing to SNS:", e)  # Log any errors
    else:
        print("No S3 records found in the event. This might be an unexpected trigger.")

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent with S3 event details (if available).')
    }
