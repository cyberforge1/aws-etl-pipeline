import boto3
import datetime
import os

# Configuration
BUCKET_NAME = 'etl-raw-zone-bucket'  # Replace with your Raw Zone S3 bucket name
REGION_NAME = 'ap-southeast-2'       # Replace with your AWS region

# Initialize S3 client
s3_client = boto3.client('s3', region_name=REGION_NAME)

def generate_document():
    """Generate a new document with unique content."""
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    document_content = f"This is a new document generated at {timestamp}.\n"
    document_name = f"document_{timestamp}.txt"
    
    # Write content to a local file
    with open(document_name, 'w') as file:
        file.write(document_content)
    
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
