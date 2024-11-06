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
    account_id = os.getenv('AWS_ACCOUNT_ID')  # Get the account ID from the environment

    # Publish a message to the SNS topic
    response = sns_client.publish(
        TopicArn=f'arn:aws:sns:ap-southeast-2:{account_id}:lambda-completion-topic',
        Message=json.dumps({'default': 'Lambda function has completed execution'}),
        Subject='Lambda Execution Notification',
        MessageStructure='json'
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda! Notification sent.')
    }
