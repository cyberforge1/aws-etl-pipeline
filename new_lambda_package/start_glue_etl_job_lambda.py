# start_glue_etl_job_lambda.py

import boto3
import os

glue_client = boto3.client('glue')

def start_glue_etl_job_lambda(event, context):
    """Lambda function to start the Glue ETL job for processing data."""
    print("Lambda function invoked to start Glue ETL job.")
    
    # Glue Job Name from environment variable
    glue_job_name = os.environ.get("GLUE_JOB_NAME", "etl-job")
    print(f"Starting Glue job: {glue_job_name}")

    try:
        # Start the Glue ETL job
        response = glue_client.start_job_run(JobName=glue_job_name)
        job_run_id = response['JobRunId']
        print(f"Glue ETL job started successfully with JobRunId: {job_run_id}")
        
        return {
            'statusCode': 200,
            'body': f'Glue ETL job started successfully with JobRunId: {job_run_id}'
        }

    except Exception as e:
        print(f"Error starting Glue ETL job: {e}")
        return {
            'statusCode': 500,
            'body': f'Failed to start Glue ETL job: {str(e)}'
        }
