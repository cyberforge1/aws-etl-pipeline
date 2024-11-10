# glue_etl_script.py

# This script is a simple AWS Glue job that copies files from one S3 bucket to another.

import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

raw_bucket = "etl-raw-zone-bucket"
processed_bucket = "etl-processed-zone-bucket"

s3_client = boto3.client("s3")

try:
    logger.info(f"Starting Glue job with raw bucket: {raw_bucket} and processed bucket: {processed_bucket}")
    
    logger.info("Listing files in the raw S3 bucket...")
    response = s3_client.list_objects_v2(Bucket=raw_bucket)
    
    if 'Contents' in response:
        logger.info(f"Found {len(response['Contents'])} file(s) in the raw bucket.")
        
        for obj in response['Contents']:
            key = obj['Key']
            logger.info(f"Preparing to copy file: {key}")
            
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

logger.info("Committing the Glue job.")
job.commit()
logger.info("Glue job committed successfully.")
