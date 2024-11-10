# 'lambda_package/lambda_function.py'

import boto3
import json
import os

sns_client = boto3.client('sns')
glue_client = boto3.client('glue')

def lambda_handler(event, context):
    """Lambda function triggered by S3 events, sends a notification via SNS, and starts the Glue Crawler."""
    print("Lambda function invoked.")
    print("Received event:", json.dumps(event, indent=2))  # Log the S3 event data in detail

    # Get AWS Region from the environment variable
    region = os.environ['AWS_REGION']
    print("Environment - AWS_REGION:", region)

    # Get AWS Account ID using STS
    sts_client = boto3.client('sts')
    account_id = sts_client.get_caller_identity()['Account']
    print("Environment - AWS_ACCOUNT_ID:", account_id)

    # Check if event contains Records to avoid UnboundLocalError
    if 'Records' in event and event['Records']:
        # Extract bucket and object key from the event
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            print(f"New object created in S3 - Bucket: {bucket_name}, Key: {object_key}")

            # Construct the SNS topic ARN
            topic_arn = f'arn:aws:sns:{region}:{account_id}:lambda-completion-topic'
            print("SNS Topic ARN:", topic_arn)

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

            # Start the Glue Crawler only if it's not already running
            try:
                crawler_name = 'etl-crawler'  # Replace with your Glue Crawler name if different

                # Get the current state of the crawler
                crawler = glue_client.get_crawler(Name=crawler_name)
                crawler_state = crawler['Crawler']['State']
                print(f"Current state of the crawler '{crawler_name}': {crawler_state}")

                # Only start the crawler if it's in the 'READY' state
                if crawler_state == 'READY':
                    glue_response = glue_client.start_crawler(Name=crawler_name)
                    print("Glue Crawler started:", glue_response)
                else:
                    print(f"Crawler '{crawler_name}' is not in a 'READY' state and cannot be started.")
            except Exception as e:
                print("Error starting Glue Crawler:", e)  # Log any errors

    else:
        print("No S3 records found in the event. This might be an unexpected trigger.")

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent and Glue Crawler triggered (if S3 event present).')
    }