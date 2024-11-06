# 's3.tf'

resource "aws_s3_bucket" "raw_zone" {
  bucket = "etl-raw-zone-bucket"
}

# Configure S3 Event Notification to trigger Lambda on new object creation
resource "aws_s3_bucket_notification" "raw_zone_notification" {
  bucket = aws_s3_bucket.raw_zone.id

  # Adding an explicit dependency on Lambda permission
  depends_on = [aws_lambda_permission.allow_s3_invoke]

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_ingest_lambda.arn
    events              = ["s3:ObjectCreated:*"]  # Trigger on all object creation events
  }
}

resource "aws_s3_bucket" "processed_zone" {
  bucket = "etl-processed-zone-bucket"
}

resource "aws_s3_object" "raw_data_json" {
  bucket = aws_s3_bucket.raw_zone.id
  key    = "data.json"
  source = "data/data.json"
  acl    = "private"
}
