resource "aws_s3_bucket" "beis-orp-datalake" {
  bucket = "beis-${local.environment}-datalake"
}

resource "aws_s3_bucket_acl" "beis-orp-datalake" {
  bucket = aws_s3_bucket.beis-orp-datalake.id
  acl    = "private"
}

resource "aws_s3_bucket" "beis-orp-upload" {
  bucket = "beis-${local.environment}-upload"
}

resource "aws_s3_bucket_acl" "beis-orp-upload" {
  bucket = aws_s3_bucket.beis-orp-upload.id
  acl    = "private"
}

resource "aws_s3_bucket" "beis-orp-clustering-models" {
  bucket = "beis-${local.environment}-clustering-models"
}

#resource "aws_s3_bucket_acl" "beis-orp-clustering-models" {
#  bucket = "beis-${local.environment}-clustering-models"
#  acl    = "private"
#}

resource "aws_s3_bucket" "beis-orp-graph-database" {
  bucket = "beis-${local.environment}-graph-database"
}

resource "aws_s3_bucket_acl" "beis-orp-graph-database" {
  bucket = "beis-${local.environment}-graph-database"
  acl    = "private"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.beis-orp-upload.id
  eventbridge = true
}
