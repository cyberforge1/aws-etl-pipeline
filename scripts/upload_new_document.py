# 'scripts/upload_new_document.py'

import boto3
import datetime
import json
import os
import random

# Configuration
BUCKET_NAME = 'etl-raw-zone-bucket'  # Replace with your Raw Zone S3 bucket name

# Get the AWS region from an environment variable
REGION_NAME = os.environ.get('AWS_REGION')

if not REGION_NAME:
    # If AWS_REGION is not set, you can set a default region or handle the error
    REGION_NAME = 'ap-southeast-2'  # Default region (optional)
    # Alternatively, raise an error
    # raise EnvironmentError("AWS_REGION environment variable is not set.")

# Initialize S3 client
s3_client = boto3.client('s3', region_name=REGION_NAME)

def generate_random_data():
    """Generate random JSON data similar to the given structure."""
    data = [
        {
            "id": random.randint(1, 100),
            "name": random.choice(["John Doe", "Jane Smith", "Alice Brown", "Bob White"]),
            "email": f"{random.choice(['johndoe', 'janesmith', 'alicebrown', 'bobwhite'])}@example.com",
            "age": random.randint(20, 40),
            "country": random.choice(["Australia", "Canada", "USA", "UK"])
        }
    ]
    return data

def generate_document():
    """Generate a new JSON document with randomized content."""
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    document_name = f"document_{timestamp}.json"
    document_content = generate_random_data()
    
    # Write JSON content to a local file
    with open(document_name, 'w') as file:
        json.dump(document_content, file)
    
    return document_name

def upload_document(document_name):
    """Upload the generated document to the specified S3 bucket without a prefix."""
    s3_key = document_name  # Store at the root of the bucket, without prefix
    
    try:
        s3_client.upload_file(document_name, BUCKET_NAME, s3_key)
        print(f"Uploaded {document_name} to s3://{BUCKET_NAME}/{s3_key}")
    except Exception as e:
        print(f"Error uploading {document_name}: {e}")
    finally:
        # Clean up the local file after uploading
        os.remove(document_name)

def main():
    document_name = generate_document()
    upload_document(document_name)

if __name__ == "__main__":
    main()
