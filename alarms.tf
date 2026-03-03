resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.application_name}-${var.environment}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 5
  alarm_description   = "Error rate more 5% during 10 min"
  treat_missing_data  = "notBreaching"

  metric_query {
    id = "errors"

    metric {
      namespace   = var.namespace
      metric_name = "OrderErrors"
      period      = 300
      stat        = "Sum"
      dimensions = {
        Application = var.application_name
        Environment = var.environment
      }
    }
  }

  metric_query {
    id = "orders"

    metric {
      namespace   = var.namespace
      metric_name = "OrdersProcessed"
      period      = 300
      stat        = "Sum"
      dimensions = {
        Application = var.application_name
        Environment = var.environment
      }
    }
  }

  metric_query {
    id          = "error_rate"
    expression  = "100 * (errors / orders)"
    label       = "Error Rate"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "queue_backlog" {
  alarm_name          = "${var.application_name}-${var.environment}-queue-backlog"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 50
  metric_name         = "QueueLength"
  namespace           = var.namespace
  period              = 300
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"

  dimensions = {
    Application = var.application_name
    Environment = var.environment
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}