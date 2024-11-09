# 's3_objects.tf'

# Upload Glue ETL script to S3
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket
  key    = "script.py"
  source = "./script.py"  # Local path to the Glue ETL script
  acl    = "private"

  # Explicitly set a dependency on the glue_scripts bucket
  depends_on = [aws_s3_bucket.glue_scripts]
}
