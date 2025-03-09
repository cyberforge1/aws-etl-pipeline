# 'scripts/upload_to_processed_bucket.py'

import boto3
import datetime
import json
import os
import random

BUCKET_NAME = 'etl-processed-zone-bucket'

REGION_NAME = os.environ.get('AWS_REGION')

if not REGION_NAME:
    REGION_NAME = 'ap-southeast-2'

s3_client = boto3.client('s3', region_name=REGION_NAME)

def generate_random_data():
    data = [
        {
            "id": random.randint(1, 100),
            "name": random.choice(["John Doe", "Jane Smith", "Alice Brown", "Bob White"]),
            "email": f"{random.choice(['johndoe', 'janesmith', 'alicebrown', 'bobwhite'])}@example.com",
            "age": random.randint(20, 40),
            "country": random.choice(["Australia", "Canada", "USA", "UK"])
        }
        for _ in range(5)
    ]
    return data

def generate_document():
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    document_name = f"document_{timestamp}.json"
    document_content = generate_random_data()
    
    with open(document_name, 'w') as file:
        json.dump(document_content, file, indent=2)
    
    return document_name

def upload_document(document_name):
    s3_key = document_name
    
    try:
        s3_client.upload_file(document_name, BUCKET_NAME, s3_key)
        print(f"Uploaded {document_name} to s3://{BUCKET_NAME}/{s3_key}")
    except Exception as e:
        print(f"Error uploading {document_name}: {e}")
    finally:
        os.remove(document_name)

def main():
    document_name = generate_document()
    upload_document(document_name)

if __name__ == "__main__":
    main()
