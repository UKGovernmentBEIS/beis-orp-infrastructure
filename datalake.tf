resource "aws_lakeformation_resource" "beis-orp-datalake" {
  arn = aws_s3_bucket.beis-orp-datalake.arn
}
