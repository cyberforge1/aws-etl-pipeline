# 's3.tf'

# S3 Bucket for Raw Data
resource "aws_s3_bucket" "raw_zone" {
  bucket = "etl-raw-zone-bucket"
}

# Bucket policy to allow Glue Crawler access to Raw Zone
resource "aws_s3_bucket_policy" "raw_zone_policy" {
  bucket = aws_s3_bucket.raw_zone.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.glue_role.arn}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.raw_zone.arn}",
          "${aws_s3_bucket.raw_zone.arn}/*"
        ]
      }
    ]
  })
}

# S3 Bucket for Processed Data
resource "aws_s3_bucket" "processed_zone" {
  bucket = "etl-processed-zone-bucket"
}

# Bucket policy to allow Glue Job access to Processed Zone
resource "aws_s3_bucket_policy" "processed_zone_policy" {
  bucket = aws_s3_bucket.processed_zone.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.glue_role.arn}"
        },
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.processed_zone.arn}",
          "${aws_s3_bucket.processed_zone.arn}/*"
        ]
      }
    ]
  })
}

# S3 Bucket for Glue Scripts
resource "aws_s3_bucket" "glue_scripts" {
  bucket = "etl-glue-scripts-bucket"  # Ensure this bucket name is unique
}

# Bucket policy to allow Glue Job to read the script
resource "aws_s3_bucket_policy" "glue_scripts_policy" {
  bucket = aws_s3_bucket.glue_scripts.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.glue_role.arn}"
        },
        "Action": [
          "s3:GetObject"
        ],
        "Resource": "${aws_s3_bucket.glue_scripts.arn}/*"
      }
    ]
  })
}

# Configure S3 Event Notification to trigger Lambda on new object creation
resource "aws_s3_bucket_notification" "raw_zone_notification" {
  bucket = aws_s3_bucket.raw_zone.id

  # Adding an explicit dependency on Lambda permission
  depends_on = [aws_lambda_permission.allow_s3_invoke]

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_ingest_lambda.arn  # Trigger existing Lambda function
    events              = ["s3:ObjectCreated:*"]  # Trigger on all object creation events
  }
}
