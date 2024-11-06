# 's3.tf'

resource "aws_s3_bucket" "raw_zone" {
  bucket = "etl-raw-zone-bucket"
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
