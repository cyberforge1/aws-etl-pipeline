# 'lambda_function.py'

import boto3
import json
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    """Sample Lambda function that sends a notification via SNS on execution."""
    print("Lambda function invoked")  # Initial log to verify invocation

    account_id = os.getenv('AWS_ACCOUNT_ID')  # Get the account ID from the environment
    topic_arn = f'arn:aws:sns:ap-southeast-2:{account_id}:lambda-completion-topic'

    # Create the message content
    message = {
        'default': 'Lambda function has successfully completed execution.',
        'email': (
            "Hello,\n\n"
            "This is to inform you that the Lambda function has successfully completed its execution.\n\n"
            "Regards,\nYour Lambda Notification System"
        )
    }

    # Try to publish a message to the SNS topic and log the result
    try:
        # Publish a message to the SNS topic with a custom message structure
        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=json.dumps(message),
            Subject='Lambda Execution Notification',
            MessageStructure='json'
        )
        print("SNS Publish Response:", response)  # Log the SNS publish response
    except Exception as e:
        print("Error publishing to SNS:", e)  # Log any errors

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda! Notification sent with custom message.')
    }
