# script.py

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Initialize Glue context and job
args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Source and target bucket paths
raw_bucket = "s3://etl-raw-zone-bucket/"
processed_bucket = "s3://etl-processed-zone-bucket/"

try:
    # Read JSON files from the raw bucket
    dynamic_frame = glueContext.create_dynamic_frame.from_options(
        connection_type="s3",
        connection_options={"paths": [raw_bucket], "recurse": True},
        format="json"
    )
    
    # Check if data exists before writing
    if dynamic_frame.count() > 0:
        # Write the data to the processed bucket in JSON format
        glueContext.write_dynamic_frame.from_options(
            frame=dynamic_frame,
            connection_type="s3",
            connection_options={"path": processed_bucket},
            format="json"
        )
        print("Data successfully written to the processed bucket.")
    else:
        print("No data to write.")
        
except Exception as e:
    print(f"Error occurred: {e}")

# Commit the job
job.commit()
