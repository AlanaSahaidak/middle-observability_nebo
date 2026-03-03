resource "aws_cloudwatch_dashboard" "nebo_dashboard" {
  dashboard_name = "${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              var.namespace,
              "OrdersProcessed",
              "Application", var.application_name,
              "Environment", var.environment
            ]
          ]
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 300
          title  = "Orders Processed (5 min)"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              var.namespace,
              "Revenue",
              "Application", var.application_name,
              "Environment", var.environment
            ]
          ]
          view   = "timeSeries"
          region = var.region
          stat   = "Sum"
          period = 300
          title  = "Revenue (5 min)"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              var.namespace,
              "OrderProcessingTime",
              "Application", var.application_name,
              "Environment", var.environment
            ]
          ]
          view   = "timeSeries"
          region = var.region
          stat   = "Average"
          period = 300
          title  = "Average Processing Time"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              var.namespace,
              "QueueLength",
              "Application", var.application_name,
              "Environment", var.environment
            ]
          ]
          view   = "timeSeries"
          region = var.region
          stat   = "Maximum"
          period = 300
          title  = "Queue Length (Peak)"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          metrics = [
            [
              var.namespace,
              "OrderErrors",
              "Application", var.application_name,
              "Environment", var.environment,
              { id = "m1", stat = "Sum" }
            ],
            [
              var.namespace,
              "OrdersProcessed",
              "Application", var.application_name,
              "Environment", var.environment,
              { id = "m2", stat = "Sum" }
            ],
            [
              {
                expression = "100 * (m1 / m2)",
                label      = "Error Rate (%)",
                id         = "e1"
              }
            ]
          ]

          view   = "timeSeries"
          region = var.region
          period = 300
          title  = "Error Rate (%)"
        }
      }
    ]
  })
}