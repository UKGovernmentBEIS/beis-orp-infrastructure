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
  name     = "sample-state-machine"
  role_arn = "${aws_iam_role.iam_for_step_function.arn}"

  definition = <<EOF
{
  "StartAt": "random-number-generator-lambda-config",
  "States": {
    "random-number-generator-lambda-config": {
      "Comment": "To configure the random-number-generator-lambda.",
      "Type": "Pass",
      "Result": {
          "min": 1,
          "max": 10
        },
      "ResultPath": "$",
      "Next": "random-number-generator-lambda"
    },
    "random-number-generator-lambda": {
      "Comment": "Generate a number based on input.",
      "Type": "Task",
      "Resource": "${module.pdf_to_text.lambda_function_arn}",
      "Next": "send-notification-if-less-than-5"
    },
    "send-notification-if-less-than-5": {
      "Comment": "A choice state to decide to send out notification for <5 or trigger power of three lambda for >5.",
      "Type": "Choice",
      "Choices": [
        {
            "Variable": "$",
            "NumericGreaterThanEquals": 5,
            "Next": "power-of-three-lambda"
        },
        {
          "Variable": "$",
          "NumericLessThan": 5,
          "Next": "send-multiple-notification"
        }
      ]
    },
    "power-of-three-lambda": {
      "Comment": "Increase the input to power of 3 with customized input.",
      "Type": "Task",
      "Parameters" : {
        "base.$": "$",
        "exponent": 3
      },
      "Resource": "${module.pdf_to_text.lambda_function_arn}",
      "End": true
    },
    "send-multiple-notification": {
      "Comment": "Trigger multiple notification using AWS SNS",
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
         "StartAt": "send-sms-notification",
         "States": {
            "send-sms-notification": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sns:publish",
              "Parameters": {
                "Message": "SMS: Random number is less than 5 $"
              },
              "End": true
            }
         }
       }
      ]
    }
  }
}
EOF

  depends_on = []

}
