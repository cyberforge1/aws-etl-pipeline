# 'lambda_functions/lambda_package/lambda_function.py'

import boto3
import json
import os

sns_client = boto3.client('sns')
glue_client = boto3.client('glue')

def lambda_handler(event, context):
    print("Lambda function invoked.")
    print("Received event:", json.dumps(event, indent=2))

    region = os.environ['AWS_REGION']
    print("Environment - AWS_REGION:", region)

    sts_client = boto3.client('sts')
    account_id = sts_client.get_caller_identity()['Account']
    print("Environment - AWS_ACCOUNT_ID:", account_id)

    if 'Records' in event and event['Records']:
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            print(f"New object created in S3 - Bucket: {bucket_name}, Key: {object_key}")

            topic_arn = f'arn:aws:sns:{region}:{account_id}:lambda-completion-topic'
            print("SNS Topic ARN:", topic_arn)

            message = {
                'default': 'Lambda function has successfully processed an S3 event.',
                'email': (
                    f"Hello,\n\n"
                    f"A new file has been uploaded to S3 bucket '{bucket_name}' with key '{object_key}'.\n\n"
                    "Regards,\nYour Lambda Notification System"
                )
            }

            try:
                response = sns_client.publish(
                    TopicArn=topic_arn,
                    Message=json.dumps(message),
                    Subject='Lambda S3 Event Notification',
                    MessageStructure='json'
                )
                print("SNS Publish Response:", response)
            except Exception as e:
                print("Error publishing to SNS:", e)


            try:
                crawler_name = 'etl-crawler'

                crawler = glue_client.get_crawler(Name=crawler_name)
                crawler_state = crawler['Crawler']['State']
                print(f"Current state of the crawler '{crawler_name}': {crawler_state}")

                if crawler_state == 'READY':
                    glue_response = glue_client.start_crawler(Name=crawler_name)
                    print("Glue Crawler started:", glue_response)
                else:
                    print(f"Crawler '{crawler_name}' is not in a 'READY' state and cannot be started.")
            except Exception as e:
                print("Error starting Glue Crawler:", e)

    else:
        print("No S3 records found in the event. This might be an unexpected trigger.")

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent and Glue Crawler triggered (if S3 event present).')
    }