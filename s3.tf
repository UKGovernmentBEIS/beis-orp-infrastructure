resource "aws_s3_bucket" "beis-orp-ingest" {
  bucket = "beis-orp-${local.environment}-ingest"
}

resource "aws_s3_bucket_acl" "beis-orp-ingest" {
  bucket = aws_s3_bucket.beis-orp-ingest.id
  acl    = "private"
}
