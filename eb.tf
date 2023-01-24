resource "aws_cloudwatch_event_rule" "eb_trigger" {
  name        = "eb_trigger"
  description = "Capture each Created Object"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["beis-orp-dev-upload"]
    },
    "object": {
      "key": [{
        "prefix": "trigger-pipeline/"
      }]
    }
  }
}
EOF
}
