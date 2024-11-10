# script.py

# This script is a simple AWS Glue job that copies files from one S3 bucket to another.

import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Glue context and job
args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Source and target bucket names
raw_bucket = "etl-raw-zone-bucket"
processed_bucket = "etl-processed-zone-bucket"

# Initialize the S3 client
s3_client = boto3.client("s3")

try:
    logger.info(f"Starting Glue job with raw bucket: {raw_bucket} and processed bucket: {processed_bucket}")
    
    # Stage 1: List files in the raw bucket
    logger.info("Listing files in the raw S3 bucket...")
    response = s3_client.list_objects_v2(Bucket=raw_bucket)
    
    if 'Contents' in response:
        logger.info(f"Found {len(response['Contents'])} file(s) in the raw bucket.")
        
        # Stage 2: Iterate over each file and copy it to the processed bucket
        for obj in response['Contents']:
            key = obj['Key']
            logger.info(f"Preparing to copy file: {key}")
            
            # Define source and destination for copy
            copy_source = {'Bucket': raw_bucket, 'Key': key}
            try:
                logger.info(f"Copying {key} from {raw_bucket} to {processed_bucket}...")
                s3_client.copy_object(CopySource=copy_source, Bucket=processed_bucket, Key=key)
                logger.info(f"Successfully copied {key} to {processed_bucket}")
            except Exception as e:
                logger.error(f"Failed to copy {key} from {raw_bucket} to {processed_bucket}: {e}")
    else:
        logger.warning("No files found in the raw bucket.")
    
except Exception as e:
    logger.error(f"An error occurred during the Glue job: {e}")

# Stage 3: Commit the Glue job
logger.info("Committing the Glue job.")
job.commit()
logger.info("Glue job committed successfully.")
