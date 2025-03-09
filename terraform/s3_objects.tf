# 'terraform/s3_objects.tf'

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket
  key    = "glue_etl_script.py"  # Including the `.py` extension here is more descriptive
  source = "${path.module}/../glue_etl_script.py"  # Updated path to locate the file from `terraform/`
  acl    = "private"

  depends_on = [aws_s3_bucket.glue_scripts]
}
