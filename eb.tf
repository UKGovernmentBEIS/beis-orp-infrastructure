resource "aws_cloudwatch_event_rule" "eb_trigger" {
  name        = "eb_trigger"
  description = "Capture each Created Object"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.beis-orp-upload.id}"]
    },
    "object": {
      "key": [{
        "anything-but": {
          "prefix": "unconfirmed/"
        }
      }]
    }
  }
}
EOF
}
