# s3.tf
resource "aws_s3_bucket" "raw_zone" {
  bucket = "etl-raw-zone-bucket"
}

resource "aws_s3_bucket" "processed_zone" {
  bucket = "etl-processed-zone-bucket"
}
