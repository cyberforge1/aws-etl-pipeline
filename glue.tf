# 'glue.tf'

# Glue Database for storing crawler metadata
resource "aws_glue_catalog_database" "etl_database" {
  name = "etl_database"
}

# Glue Crawler
resource "aws_glue_crawler" "etl_crawler" {
  name          = "etl-crawler"
  role          = aws_iam_role.glue_role.arn  # Reference the Glue-specific IAM role
  database_name = aws_glue_catalog_database.etl_database.name

  s3_target {
    path = "s3://${aws_s3_bucket.raw_zone.bucket}"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
}

# Glue Job for ETL processing
resource "aws_glue_job" "etl_job" {
  name        = "etl-job"
  role_arn    = aws_iam_role.glue_role.arn  # Use the Glue-specific IAM role
  command {
    name            = "glueetl"
    script_location = "s3://path-to-your-script-location/script.py"  # Update with the actual S3 path for your ETL script
    python_version  = "3"
  }
  glue_version    = "3.0"  # Adjust if needed
  max_capacity    = 2      # Adjust based on the job's resource requirements
  execution_property {
    max_concurrent_runs = 1
  }
  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-disable"
  }
}
