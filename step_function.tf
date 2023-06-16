resource "aws_iam_role" "iam_for_step_function" {
  name = "stepFunctionExecutionIAM"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
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
  name = "stepFunctionSQSInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
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

resource "aws_iam_role_policy_attachment" "policy_invoke_stepFunction" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = aws_iam_policy.policy_invoke_stepFunction.arn
}

resource "aws_iam_policy" "policy_invoke_lambda" {
  name = "stepFunctionLambdaFunctionInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:*"
            ],
            "Resource": [
                "${module.orpml_ingest.lambda_function_arn}:*",
                "${module.pdf_to_orpml.lambda_function_arn}:*",
                "${module.docx_to_orpml.lambda_function_arn}:*",
                "${module.odf_to_orpml.lambda_function_arn}:*",
                "${module.html_to_orpml.lambda_function_arn}:*",
                "${module.title_generation.lambda_function_arn}:*",
                "${module.date_generation.lambda_function_arn}:*",
                "${module.keyword_extraction.lambda_function_arn}:*",
                "${module.summarisation.lambda_function_arn}:*",
                "${module.legislative_origin_extraction.lambda_function_arn}:*",
                "${module.finalise_orpml.lambda_function_arn}:*",
                "${module.typedb_ingestion.lambda_function_arn}:*",
                "${module.failure_notification.lambda_function_arn}:*",
                "${module.check_duplicate.lambda_function_arn}:*"
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
  name = "stepFunctionS3AccessPolicy"

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

resource "aws_cloudwatch_event_target" "SFNTarget" {
  rule     = aws_cloudwatch_event_rule.eb_trigger.name
  arn      = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn = aws_iam_role.iam_for_step_function.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "orp_document_ingestion"
  role_arn = aws_iam_role.iam_for_step_function.arn

  definition = <<EOF
{
  "StartAt": "Assess Document Suffix",
  "States": {
    "Assess Document Suffix": {
      "Type": "Choice",
      "Choices": [
        {
          "Or": [
            {
              "Variable": "$.detail.object.key",
              "StringMatches": "*.doc"
            },
            {
              "Variable": "$.detail.object.key",
              "StringMatches": "*.docx"
            }
          ],
          "Next": "Convert DOCX to ORPML"
        },
        {
          "Variable": "$.detail.object.key",
          "StringMatches": "*.pdf",
          "Next": "Convert PDF to ORPML"
        },
        {
          "Variable": "$.detail.object.key",
          "StringMatches": "*.orpml",
          "Next": "Ingest ORPML Document"
        },
        {
          "Or": [
            {
              "Variable": "$.detail.object.key",
              "StringMatches": "*.odt"
            },
            {
              "Variable": "$.detail.object.key",
              "StringMatches": "*.odp"
            },
            {
              "Variable": "$.detail.object.key",
              "StringMatches": "*.odf"
            }
          ],
          "Next": "Convert ODF to ORPML"
        },
        {
          "Variable": "$.detail.object.key",
          "StringEquals": "HTML",
          "Next": "Convert HTML to ORPML"
        }
      ],
      "Default": "Fail"
    },
    "Ingest ORPML Document": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:orpml_ingest:$LATEST"
      },
      "Next": "Check Duplicates",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Convert PDF to ORPML": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:pdf_to_orpml:$LATEST"
      },
      "Next": "Check Duplicates",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Convert DOCX to ORPML": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:docx_to_orpml:$LATEST"
      },
      "Next": "Check Duplicates",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Convert ODF to ORPML": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:odf_to_orpml:$LATEST"
      },
      "Next": "Check Duplicates",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Convert HTML to ORPML": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:html_to_orpml:$LATEST"
      },
      "Next": "Check Duplicates",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Failure Notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:failure_notification:$LATEST"
      },
      "Next": "Fail",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Fail",
          "ResultPath": "$"
        }
      ]
    },
    "Check Duplicates": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:check_duplicate:$LATEST"
      },
      "Next": "Parallel",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Parallel": {
      "Type": "Parallel",
      "Next": "Finalise ORPML",
      "ResultPath": "$.enrichments",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ],
      "Branches": [
        {
          "StartAt": "Date Generation",
          "States": {
            "Date Generation": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:date_generation:$LATEST"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "Title Generation",
          "States": {
            "Title Generation": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:title_generation:$LATEST"
              },
              "Next": "Keyword Extraction"
            },
            "Keyword Extraction": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:keyword_extraction:$LATEST"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "Summarisation",
          "States": {
            "Summarisation": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:summarisation:$LATEST"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "Legislative Origin Extraction",
          "States": {
            "Legislative Origin Extraction": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:legislative_origin_extraction:$LATEST"
              },
              "End": true
            }
          }
        }
      ]
    },
    "Finalise ORPML": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:finalise_orpml:$LATEST"
      },
      "Next": "TypeDB Ingestion",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },        
    "TypeDB Ingestion": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:function:typedb_ingestion:$LATEST"
      },
      "Next": "Success",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "Failure Notification",
          "ResultPath": "$.error"
        }
      ]
    },
    "Success": {
      "Type": "Succeed"
    },
    "Fail": {
      "Type": "Fail"
    }
  },
  "TimeoutSeconds": 3600,
  "Comment": "Ingestion pipeline for BEIS BRE ORP"
}
EOF

  depends_on = []

}

resource "aws_iam_policy" "policy_invoke_stepFunction" {
  name = "stepFunctionInvokeStepFunction"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
             "Action": [ "states:StartExecution" ],
            "Resource": [ "${aws_sfn_state_machine.sfn_state_machine.arn}" ]
        }
     ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_cw" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "policy_sf" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

resource "aws_iam_role_policy_attachment" "policy_eb" {
  role       = aws_iam_role.iam_for_step_function.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}
