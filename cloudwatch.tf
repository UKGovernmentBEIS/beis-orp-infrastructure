resource "aws_cloudwatch_log_group" "beis_orp" {
  name              = "/aws/ecs/beis_orp"
  retention_in_days = 14
}

resource "aws_cloudwatch_dashboard" "monitoring" {
  dashboard_name = "monitoring"
  dashboard_body = jsonencode(
    {
      "widgets" : [
        {
          "height" : 6,
          "width" : 4,
          "y" : 0,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "CPU Utilization",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              [{ "id" : "expr1m0", "label" : "ecs_webserver", "expression" : "mm1m0 * 100 / mm0m0", "stat" : "Average" }],
              ["ECS/ContainerInsights", "CpuReserved", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "id" : "mm0m0", "visible" : false, "stat" : "Sum" }],
              [".", "CpuUtilized", ".", ".", ".", ".", { "id" : "mm1m0", "visible" : false, "stat" : "Sum" }]
            ],
            "liveData" : false,
            "period" : 60,
            "yAxis" : {
              "left" : {
                "min" : 0,
                "showUnits" : false,
                "label" : "Percent"
              }
            }
          }
        },
        {
          "height" : 6,
          "width" : 4,
          "y" : 0,
          "x" : 4,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Memory Utilization",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              [{ "id" : "expr1m0", "label" : "ecs_webserver", "expression" : "mm1m0 * 100 / mm0m0", "stat" : "Average" }],
              ["ECS/ContainerInsights", "MemoryReserved", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "id" : "mm0m0", "visible" : false, "stat" : "Sum" }],
              [".", "MemoryUtilized", ".", ".", ".", ".", { "id" : "mm1m0", "visible" : false, "stat" : "Sum" }]
            ],
            "liveData" : false,
            "period" : 60,
            "yAxis" : {
              "left" : {
                "min" : 0,
                "showUnits" : false,
                "label" : "Percent"
              }
            }
          }
        },
        {
          "height" : 6,
          "width" : 4,
          "y" : 0,
          "x" : 8,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Network TX",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              [{ "id" : "expr1m0", "label" : "ecs_webserver", "expression" : "mm0m0", "stat" : "Average" }],
              ["ECS/ContainerInsights", "NetworkTxBytes", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "id" : "mm0m0", "visible" : false, "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60,
            "yAxis" : {
              "left" : {
                "showUnits" : false,
                "label" : "Bytes/Second"
              }
            }
          }
        },
        {
          "height" : 6,
          "width" : 3,
          "y" : 0,
          "x" : 12,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Disk Utilization",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              [{ "id" : "expr1m0", "label" : "ecs_webserver", "expression" : "mm1m0 * 100 / mm0m0", "stat" : "Average" }],
              ["ECS/ContainerInsights", "EphemeralStorageReserved", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "id" : "mm0m0", "visible" : false, "stat" : "Sum" }],
              [".", "EphemeralStorageUtilized", ".", ".", ".", ".", { "id" : "mm1m0", "visible" : false, "stat" : "Sum" }]
            ],
            "liveData" : false,
            "period" : 60,
            "yAxis" : {
              "left" : {
                "min" : 0,
                "showUnits" : false,
                "label" : "Percent"
              }
            }
          }
        },
        {
          "height" : 6,
          "width" : 3,
          "y" : 0,
          "x" : 15,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Network RX",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              [{ "id" : "expr1m0", "label" : "ecs_webserver", "expression" : "mm0m0", "stat" : "Average" }],
              ["ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "id" : "mm0m0", "visible" : false, "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60,
            "yAxis" : {
              "left" : {
                "showUnits" : false,
                "label" : "Bytes/Second"
              }
            }
          }
        },
        {
          "height" : 6,
          "width" : 3,
          "y" : 0,
          "x" : 18,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Number of Desired Tasks",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              ["ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60
          }
        },
        {
          "height" : 6,
          "width" : 3,
          "y" : 0,
          "x" : 21,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Number of Running Tasks",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60
          }
        },
        {
          "height" : 6,
          "width" : 4,
          "y" : 6,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Number of Pending Tasks",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              ["ECS/ContainerInsights", "PendingTaskCount", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60
          }
        },
        {
          "height" : 6,
          "width" : 4,
          "y" : 6,
          "x" : 4,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Number of Task Sets",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              ["ECS/ContainerInsights", "TaskSetCount", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60
          }
        },
        {
          "height" : 6,
          "width" : 4,
          "y" : 6,
          "x" : 8,
          "type" : "metric",
          "properties" : {
            "region" : "eu-west-2",
            "title" : "Number of Deployments",
            "legend" : {
              "position" : "bottom"
            },
            "timezone" : "Local",
            "metrics" : [
              ["ECS/ContainerInsights", "DeploymentCount", "ClusterName", "ecs_webserver", "ServiceName", "ecs_webserver", { "stat" : "Average" }]
            ],
            "liveData" : false,
            "period" : 60
          }
        }
      ]
    }
  )
}

resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "pipeline-monitoring"
  dashboard_body = jsonencode({
    id    = "pipeline-monitoring"
    start = "-PT168H"
    widgets = [
      {
        type   = "metric"
        height = 6
        width  = 12
        properties = {
          legend = {
            position = "hidden"
          }
          stat     = "Average"
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
              aws_sfn_state_machine.sfn_state_machine.arn,
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
          title   = "Pipeline Execution Duration"
          view    = "timeSeries"
          yAxis = {
            left = {
              label     = "Duration (s)"
              showUnits = false
            }
          }
        }
        x = 12
        y = 12
      },
      {
        height = 6
        width  = 0
        properties = {
          legend = {
            position = "right"
          }
          yAxis = {
            left = {
              showUnits = false
          } }
          liveData = false
          metrics = [
            [
              "AWS/States",
              "ExecutionsSucceeded",
              "StateMachineArn",
              aws_sfn_state_machine.sfn_state_machine.arn,
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
        y     = 18
        x     = 0
      },
      {
        height = 6
        properties = {
          legend = {
            position = "hidden"
          }
          yAxis = {
            left = {
          showUnits = false } }
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
              aws_sfn_state_machine.sfn_state_machine.arn,
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
        y     = 18
      },
      {
        height = 6
        properties = {
          legend = {
            position = "right"
          }
          yAxis = {
            left = {
              label     = ""
              showUnits = false
            }
            right = {
              showUnits = false
            }
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
              "orpml_ingest",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "finalise_orpml",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "pdf_to_orpml",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "docx_to_orpml",
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
              "html_to_orpml",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "delete_document",
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
              "failure_notification",
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
        height = 6
        properties = {
          legend = {
            position = "right"
          }
          yAxis = {
            left = {
              label     = "Duration (s)"
              showUnits = false
          } }
          liveData = false
          metrics = [
            [
              {
                expression = "METRICS()/1000"
                id         = "e1"
                label      = ""
                period     = 3600
                region     = "eu-west-2"
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
              "pdf_to_orpml",
              {
                id      = "m2"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "docx_to_orpml",
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
              "html_to_orpml",
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
              "failure_notification",
              {
                region = "eu-west-2"
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
            [
              "...",
              "delete_document",
              {
                id      = "m14"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "orpml_ingest",
              {
                id      = "m15"
                region  = "eu-west-2"
                visible = false
              },
            ],
            [
              "...",
              "finalise_orpml",
              {
                id      = "m15"
                region  = "eu-west-2"
                visible = false
              },
            ],
          ]
          period  = 3600
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
        height = 6
        properties = {
          legend = {
            position = "right"
          }
          period  = 3600
          stacked = false
          stat    = "Sum"
          view    = "timeSeries"
          yAxis = {
            left = {
              label     = ""
              showUnits = false
            }
          }
          liveData = false
          metrics = [
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              "legislative_origin_extraction",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "orpml_ingest",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "finalise_orpml",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "pdf_to_orpml",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "docx_to_orpml",
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
              "html_to_orpml",
              {
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "delete_document",
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
              "failure_notification",
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
          region = "eu-west-2"
          title  = "Lambda Errors"
        }
        type  = "metric"
        width = 12
        x     = 0
        y     = 6
      },
      {
        "height" = 6,
        "properties" = {
          "legend" = {
            "position" = "hidden"
          },
          yAxis = {
            left = {
              label     = ""
              showUnits = false
          } }
          "liveData" = false,
          "metrics" = [
            [
              {
                expression = "100*(m1-m2)/m1"
                id         = "e1"
                label      = ""
                period     = 3600
                region     = "eu-west-2"
              },
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
        "y"     = 6
      },
      {
        height = 6
        properties = {
          legend = {
            position = "right"
          }
          metrics = [
            [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              "odf_to_orpml",
              {
                label  = "ODF"
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "orpml_ingest",
              {
                label  = "ORPML"
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "finalise_orpml",
              {
                label  = "ORPML"
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "pdf_to_orpml",
              {
                label  = "PDF"
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "html_to_orpml",
              {
                label  = "HTML"
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "docx_to_orpml",
              {
                label  = "DOCX"
                region = "eu-west-2"
              },
            ],
            [
              "...",
              "odf_to_orpml",
              {
                label  = "ODF"
                region = "eu-west-2"
              },
            ],
          ]
          period  = 86400
          region  = "eu-west-2"
          stacked = false
          stat    = "Average"
          title   = "Pipeline Throughput per Document Type"
          view    = "timeSeries"
          yAxis = {
            left = {
              label     = "Documents Ingested"
              showUnits = false
            }
            right = {
              showUnits = true
            }
          }
        }
        type  = "metric"
        width = 12
        x     = 0
        y     = 12
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "pipeline_abnormal_throughput" {
  alarm_name          = "Pipeline Abnormal Throughput"
  evaluation_periods  = 1
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  alarm_description   = "Alerts when the number of ingested documents per day is more than 2 standard deviations outside the mean"
  datapoints_to_alarm = 1
  threshold_metric_id = "ad1"
  metric_query {
    id          = "m1"
    period      = 0
    return_data = true

    metric {
      dimensions = {
        "StateMachineArn" = aws_sfn_state_machine.sfn_state_machine.arn
      }
      metric_name = "ExecutionsStarted"
      namespace   = "AWS/States"
      period      = 86400
      stat        = "Sum"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    id          = "ad1"
    label       = "ExecutionsStarted (expected)"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "pipeline_slow_execution" {
  alarm_description   = "Alerts when Step Functions is taking a long time to execute"
  alarm_name          = "Step Function Large Execution Time"
  evaluation_periods  = 1
  comparison_operator = "GreaterThanUpperThreshold"
  datapoints_to_alarm = 1
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  ok_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  threshold_metric_id = "ad1"

  metric_query {
    id          = "m1"
    period      = 0
    return_data = true

    metric {
      dimensions = {
        "StateMachineArn" = aws_sfn_state_machine.sfn_state_machine.arn
      }
      metric_name = "ExecutionTime"
      namespace   = "AWS/States"
      period      = 86400
      stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    id          = "ad1"
    label       = "ExecutionTime (expected)"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "pipeline_low_success_rate" {
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  alarm_description   = "Alerts when the Step Function success rate drops below 95%"
  alarm_name          = "Step Function Low Success Rate"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  ok_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  threshold = 95
  metric_query {
    id          = "m1"
    period      = 0
    return_data = false

    metric {
      dimensions = {
        "StateMachineArn" = aws_sfn_state_machine.sfn_state_machine.arn
      }
      metric_name = "ExecutionsFailed"
      namespace   = "AWS/States"
      period      = 86400
      stat        = "Average"
    }
  }
  metric_query {
    id          = "m2"
    period      = 0
    return_data = false

    metric {
      dimensions = {
        "StateMachineArn" = aws_sfn_state_machine.sfn_state_machine.arn
      }
      metric_name = "ExecutionsSucceeded"
      namespace   = "AWS/States"
      period      = 86400
      stat        = "Average"
    }
  }
  metric_query {
    expression  = "100*m2/(m2+m1)"
    id          = "e1"
    label       = "Step Function Success %"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "pipeline_throttling" {
  alarm_name          = "Pipeline Throttling"
  evaluation_periods  = 1
  comparison_operator = "GreaterThanUpperThreshold"
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  ok_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  alarm_description   = "Alerts when Step Function executions are being throttled"
  datapoints_to_alarm = 1
  threshold_metric_id = "ad1"
  metric_query {
    id          = "m1"
    period      = 0
    return_data = true

    metric {
      dimensions = {
        "StateMachineArn" = aws_sfn_state_machine.sfn_state_machine.arn
      }
      metric_name = "ExecutionThrottled"
      namespace   = "AWS/States"
      period      = 86400
      stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 1)"
    id          = "ad1"
    label       = "ExecutionThrottled (expected)"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_slow_execution" {
  alarm_name          = "Lambda Large Duration"
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  ok_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  alarm_description   = "Alerts when any Lambda function takes longer than 10 minutes to execute"
  datapoints_to_alarm = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 86400
  statistic           = "Maximum"
  threshold           = 600000
}

resource "aws_cloudwatch_metric_alarm" "lambda_low_success_rate" {
  alarm_name          = "Lambda Low Success Rate"
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  ok_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  alarm_description   = "Alerts when Lambda functions success rate is below 95%"
  datapoints_to_alarm = 1
  threshold           = 95
  metric_query {
    id          = "m1"
    period      = 0
    return_data = false

    metric {
      dimensions  = {}
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = 86400
      stat        = "Average"
    }
  }
  metric_query {
    id          = "m2"
    period      = 0
    return_data = false

    metric {
      dimensions  = {}
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = 86400
      stat        = "Average"
    }
  }
  metric_query {
    expression  = "100*(m2-m1/m2)"
    id          = "e1"
    label       = "Expression1"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttling" {
  alarm_name          = "Lambda Throttling"
  evaluation_periods  = 1
  comparison_operator = "GreaterThanUpperThreshold"
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts_topic.arn,
  ]
  alarm_description   = "Alerts when Lambda functions are getting throttled"
  datapoints_to_alarm = 1
  threshold_metric_id = "ad1"

  metric_query {
    id          = "m1"
    period      = 0
    return_data = true

    metric {
      dimensions  = {}
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = 86400
      stat        = "Maximum"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 1)"
    id          = "ad1"
    label       = "Throttles (expected)"
    period      = 0
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "client_app_containers_count" {
  alarm_name          = "TF Client app containers count"
  alarm_description   = "# Client app tasks below 1 There are no instances of the client application running"
  actions_enabled     = true
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 1
  treat_missing_data  = "missing"

  alarm_actions = [
    "arn:aws:sns:eu-west-2:412071276468:cloudwatch_alerts_topic"
  ]

  metric_query {
    id = "m1"
    #    period      = 60
    return_data = true

    metric {
      dimensions = {
        ClusterName = "ecs_webserver"
        ServiceName = "ecs_webserver"
      }

      metric_name = "Throttles"
      namespace   = "ECS/ContainerInsights"
      period      = 86400
      stat        = "Average"
    }
  }
}
