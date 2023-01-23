resource "aws_iam_role" "iam_for_step_function" {
  name = "stepFunctionExecutionIAM"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "policy_write_sqs" {
  name        = "stepFunctionSQSInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "sqs:SendMessage"
            ],
            "Resource": [
                  "${aws_sqs_queue.update_typedb.arn}",
                  "${aws_sqs_queue.update_typedb_deadletter.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_for_step_function_attach_policy_write_sqs" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = aws_iam_policy.policy_write_sqs.arn
}


resource "aws_iam_policy" "policy_invoke_lambda" {
  name        = "stepFunctionLambdaFunctionInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": [
                "${module.pdf_to_text.lambda_function_arn}",
                "${module.typedb_search_query.lambda_function_arn}",
                "${module.keyword_extraction.lambda_function_arn}",
                "${module.typedb_ingestion.lambda_function_arn}",
                "${module.bertopic_inference.lambda_function_arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_for_step_function_attach_policy_invoke_lambda" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = aws_iam_policy.policy_invoke_lambda.arn
}

resource "aws_iam_policy" "policy_access_s3" {
  name        = "stepFunctionS3AccessPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.beis-orp-ingest.arn}",
                "${aws_s3_bucket.beis-orp-datalake.arn}",
                "${aws_s3_bucket.beis-orp-upload.arn}",
                "${aws_s3_bucket.beis-orp-clustering-models.arn}",
                "${aws_s3_bucket.beis-orp-graph-database.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_for_step_function_attach_policy_access_s3" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = aws_iam_policy.policy_access_s3.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "orp_document_ingestion"
  role_arn = "${aws_iam_role.iam_for_step_function.arn}"

  definition = <<EOF
{
  "StartAt": "Convert to Text",
  "States": {
    "Convert to Text": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:455762151948:function:pdf_to_text:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 0,
          "BackoffRate": 2
        }
      ],
      "Next": "Parallel"
    },
    "Parallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "Keyword Extraction",
          "States": {
            "Keyword Extraction": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:455762151948:function:keyword_extraction:$LATEST"
              },
              "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException",
                    "Lambda.TooManyRequestsException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 0,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        },
        {
          "StartAt": "Topic Modelling",
          "States": {
            "Topic Modelling": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:455762151948:function:bertopic_inference:$LATEST"
              },
              "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException",
                    "Lambda.TooManyRequestsException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 0,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        }
      ],
      "Next": "TypeDB Ingestion"
    },
    "TypeDB Ingestion": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:455762151948:function:typedb_ingestion:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 0,
          "BackoffRate": 2
        }
      ],
      "Next": "Success"
    },
    "Success": {
      "Type": "Succeed"
    }
  },
  "TimeoutSeconds": 3600,
  "Comment": "Ingestion pipeline for BEIS BRE ORP"
}
EOF

  depends_on = []

}
