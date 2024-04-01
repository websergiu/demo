resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name

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
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-0d6c49134727618e9"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 Instance CPU"
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
              "AWS/ECS",
              "CPUUtilization",
              "ServiceName",
              "example",
              "ClusterName",
              "terraform-ecs-intakt-oradea"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS Service CPU"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 15
        width  = 24
        height = 6

        properties = {
          query  = "fields @timestamp, @message | sort @timestamp desc"
          region = "us-east-1"
          logGroupNames = [
            var.app_log_group_name
          ]
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 12
        width  = 3
        height = 3

        properties = {
          markdown = "Hello Intakt"
        }
      }
    ]
  })
}

