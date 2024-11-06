# AWS ETL PROCESS

1) Documents: Raw documents are the input data source.
2) Amazon S3 (Raw Zone): Raw documents are stored in an Amazon S3 bucket in the "Raw Zone" for initial storage and further processing.
3) AWS Lambda: A Lambda function is triggered to process or transform the data as needed and send it to the next stage.
4) AWS SQS: The processed data or event notifications are sent to an Amazon SQS queue for reliable, decoupled messaging.
5) AWS Glue Crawler: The crawler examines data in S3, extracts schema information, and populates the AWS Glue Data Catalog, making it queryable.
6) AWS Glue Data Catalog: Stores metadata about the raw data for easy access by other AWS services.
7) Amazon EventBridge: Monitors changes or events, triggering actions when new data is available or processing is completed.
8) AWS Glue ETL: Executes an ETL (Extract, Transform, Load) job to further process and clean the data.
9) Amazon S3 (Processed Zone): Processed data is stored in another S3 bucket ("Processed Zone") for refined and ready-to-use data.
10) Amazon EventBridge & AWS SNS: EventBridge can trigger notifications via SNS (Simple Notification Service) to inform subscribers of the pipeline status or updates.