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