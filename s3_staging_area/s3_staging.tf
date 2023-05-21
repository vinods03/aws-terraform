variable "environment" {
    type = string
}

variable "staging-bucket-name" {
  type = string
}

resource "aws_s3_bucket" "s3_staging_bucket" {
    bucket = var.staging-bucket-name

    tags = {
        Environment =  var.environment
    }
}

resource "aws_s3_bucket_notification" "s3_staging_bucket_to_event_bridge_notification" {
    bucket = aws_s3_bucket.s3_staging_bucket.id
    eventbridge = true
}

output "s3_staging_bucket_arn" {
    value = aws_s3_bucket.s3_staging_bucket.arn
}