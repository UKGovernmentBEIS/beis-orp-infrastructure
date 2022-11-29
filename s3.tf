resource "aws_s3_bucket" "beis-orp-ingest" {
  bucket = "beis-orp-${local.environment}-ingest"
}

resource "aws_s3_bucket_acl" "beis-orp-ingest" {
  bucket = aws_s3_bucket.beis-orp-ingest.id
  acl    = "private"
}

resource "aws_s3_bucket" "beis-orp-datalake" {
  bucket = "beis-orp-${local.environment}-datalake"
}

resource "aws_s3_bucket_acl" "beis-orp-datalake" {
  bucket = aws_s3_bucket.beis-orp-datalake.id
  acl    = "private"
}

resource "aws_s3_bucket" "beis-orp-upload" {
  bucket = "beis-orp-${local.environment}-upload"
}

resource "aws_s3_bucket_acl" "beis-orp-upload" {
  bucket = aws_s3_bucket.beis-orp-upload.id
  acl    = "private"
}
