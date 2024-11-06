# 'lambda_function.py'

def lambda_handler(event, context):
    """Sample Lambda function that returns a simple message."""
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
