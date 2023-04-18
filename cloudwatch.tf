resource "aws_cloudwatch_log_group" "beis_orp" {
  name              = "/aws/ecs/beis_orp"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "monthly" {
  name = "monthly"

  schedule_expression = "cron(0 0 1 * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.monthly.name
  arn  = module.typedb_backup.lambda_function_arn
}

resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "pipeline-monitoring"
  dashboard_body = jsonencode({
    id    = "pipeline-monitoring"
    start = "-PT168H"
    widgets = [
      {
        height = 9
        properties = {
          legend = {
            position = "bottom"
          }
          liveData = false,
          metrics = [
            [
              {
                expression = "METRICS()/1000"
                id         = "e1"
                label      = "Pipeline Execution Time Seconds"
                region     = "eu-west-2"
              },
            ],
            [
              "AWS/States",
              "ExecutionTime",
              "StateMachineArn",
              "arn:aws:states:eu-west-2:412071276468:stateMachine:orp_document_ingestion",
              {
                id      = "m1"
                region  = "eu-west-2"
                visible = false
                yAxis   = "left"
              },
            ]
          ],
          period  = 3600
          region  = "eu-west-2"
          stacked = false
          title   = "Pipeline Execution Time"
          view    = "timeSeries"
          yAxis = {
            left = {
              label = "Time (s)"
            }
          }
        }
        y = 8
      },
      {
        height = 8
        properties = {
          legend = {
            position = "right"
          }
          liveData = false
          metrics = [
            [
              "AWS/States",
              "ExecutionsSucceeded",
              "StateMachineArn",
              "arn:aws:states:eu-west-2:412071276468:stateMachine:orp_document_ingestion",
              {
                region = "eu-west-2"
              },
            ],
            [
              ".",
              "ExecutionsFailed",
              ".",
              ".",
              {
                region = "eu-west-2"
              },
            ],
            [
              ".",
              "ExecutionsAborted",
              ".",
              ".",
              {
                region = "eu-west-2"
              },
            ],
            [
              ".",
              "ExecutionsTimedOut",
              ".",
              ".",
              {
                region = "eu-west-2"
              },
            ],
            [
              ".",
              "ExecutionThrottled",
              ".",
              ".",
              {
                region = "eu-west-2"
              },
            ],
          ]
          period  = 3600
          region  = "eu-west-2"
          stacked = false
          stat    = "Sum"
          title   = "Pipeline Execution Results"
          view    = "timeSeries"
        }
        type  = "metric"
        width = 12
        y     = 17
      },
      {
        height = 9
        properties = {
          legend = {
            position = "bottom"
          }
          liveData = false
          metrics = [
            [
              {
                expression = "100*(m1/m2)"
                id         = "e1"
                label      = "Pipeline Execution Success Rate"
                period     = 3600
                region     = "eu-west-2"
              },
            ],
            [
              "AWS/States",
              "ExecutionsSucceeded",
              "StateMachineArn",
              "arn:aws:states:eu-west-2:412071276468:stateMachine:orp_document_ingestion",
              {
                id      = "m1"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              ".",
              "ExecutionsStarted",
              ".",
              ".",
              {
                id      = "m2"
                region  = "eu-west-2"
                visible = false
              },
            ],
          ]
          period  = 3600
          region  = "eu-west-2"
          stacked = false
          stat    = "Sum"
          title   = "Pipeline Success %"
          view    = "timeSeries"
        }
        type  = "metric"
        width = 12
        x     = 12
        y     = 8
      },
      {
        height = 4
        properties = {
          legend = {
            position = "right"
          }
          liveData = false
          metrics = [
            [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              "legislative_origin_extraction",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "pdf_to_text",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "docx_to_text",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "html_trigger",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "html_to_text",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "title_generation",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "check_duplicate",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "date_generation",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "keyword_extraction",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "summarisation",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "typedb_ingestion",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "legislation_table_update",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "typedb_search_query",
              {
                region = "eu-west-2"
              },
            ],
          ]
          period  = 3600
          region  = "eu-west-2"
          stacked = false
          stat    = "Sum"
          title   = "Lambda Invocations"
          view    = "timeSeries"
        }
        type  = "metric"
        width = 12
        x     = 0
        y     = 0
      },
      {
        height = 4
        properties = {
          legend = {
            position = "right"
          }
          liveData = false
          metrics = [
            [
              {
                expression = "METRICS()/1000"
                id         = "e1"
                label      = "Expression1"
              },
            ],
            [
              "AWS/Lambda",
              "Duration",
              "FunctionName",
              "legislative_origin_extraction",
              {
                id      = "m1"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "pdf_to_text",
              {
                id      = "m2"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "docx_to_text",
              {
                id      = "m3"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "html_trigger",
              {
                id      = "m4"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "html_to_text",
              {
                id      = "m5"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "title_generation",
              {
                id      = "m6"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "check_duplicate",
              {
                id      = "m7"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "date_generation",
              {
                id      = "m8"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "keyword_extraction",
              {
                id      = "m9"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "summarisation",
              {
                id      = "m10"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "typedb_ingestion",
              {
                id      = "m11"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "legislation_table_update",
              {
                id      = "m12"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "typedb_search_query",
              {
                id      = "m13"
                region  = "eu-west-2"
                visible = false
              },
            ],
          ]
          period  = 300
          region  = "eu-west-2"
          stacked = false
          stat    = "Average"
          title   = "Lambda Duration"
          view    = "timeSeries"
        }
        type  = "metric"
        width = 12
        x     = 12
        y     = 0
      },
      {
        height = 4
        properties = {
          legend = {
            position = "right"
          }
          liveData = false
          metrics = [
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              "legislative_origin_extraction",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "pdf_to_text",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "docx_to_text",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "html_trigger",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "html_to_text",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "title_generation",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "check_duplicate",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "date_generation",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "keyword_extraction",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "summarisation",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "typedb_ingestion",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "legislation_table_update",
              {
                period = 300
                stat   = "Sum"
              },
            ],
            [
              "...",
              "typedb_search_query",
              {
                period = 300
                stat   = "Sum"
              },
            ],
          ]
          region = "eu-west-2"
          title  = "Lambda Errors"
        }
        type  = "metric"
        width = 12
        x     = 0
        y     = 4
      },
      {
        "height" = 4,
        "properties" = {
          "legend" = {
            "position" = "right"
          },
          "liveData" = false,
          "metrics" = [
            [
              {
                "expression" = "100*(m1-m2)/m1",
                "id"         = "e1",
                "label"      = "Lambda Success %",
                "period"     = 3600
              }
            ],
            [
              "AWS/Lambda",
              "Invocations",
              {
                "id"      = "m1",
                "region"  = "eu-west-2",
                "visible" = false
              }
            ],
            [
              ".",
              "Errors",
              {
                "id"      = "m2",
                "region"  = "eu-west-2",
                "visible" = false
              }
            ]
          ],
          "period"  = 3600,
          "region"  = "eu-west-2",
          "stacked" = false,
          "stat"    = "Average",
          "title"   = "Lambda Success %",
          "view"    = "timeSeries"
        },
        "type"  = "metric",
        "width" = 12,
        "x"     = 12,
        "y"     = 4
      }
    ]
  })
}
