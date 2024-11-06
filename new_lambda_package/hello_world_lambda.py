# new_lambda_package/hello_world_lambda.py

def lambda_handler(event, context):
    print("Hello, world!")
    return {
        'statusCode': 200,
        'body': 'Hello, world!'
    }
