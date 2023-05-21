variable "environment" {
    type = string
}

variable "landing-bucket-name" {
  type = string
}

resource "aws_s3_bucket" "s3_landing_bucket" {
    bucket = var.landing-bucket-name

    tags = {
        Environment = var.environment
    }
}

resource "aws_s3_bucket_notification" "s3_landing_bucket_notification" {
    bucket = aws_s3_bucket.s3_landing_bucket.id

    queue {
    queue_arn     = aws_sqs_queue.orders_landing_area_queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sqs_queue" "orders_landing_area_queue" {
    name = "orders-landing-area-queue"
    policy = data.aws_iam_policy_document.landing_area_queue_policy.json
    visibility_timeout_seconds = 600
}

data "aws_iam_policy_document" "landing_area_queue_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:orders-landing-area-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.s3_landing_bucket.arn]
    }
  }
}

output "s3_landing_bucket_arn" {
    value = aws_s3_bucket.s3_landing_bucket.arn
}

output "s3_landing_bucket_queue_arn" {
    value = aws_sqs_queue.orders_landing_area_queue.arn
}
