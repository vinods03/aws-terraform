variable "environment" {
    type = string
}

variable "kinesis_data_stream_name" {
    type = string
}

resource "aws_kinesis_stream" "data_stream" {
    name = var.kinesis_data_stream_name
    shard_count = var.environment == "dev" ? 1 : 2
    retention_period = var.environment == "dev" ? 24 : 48

    stream_mode_details {
        stream_mode = "PROVISIONED"
    }

    tags = {
        Environment = var.environment
    }
}

output "stream_id" {
    value = aws_kinesis_stream.data_stream.id
}

output "stream_arn" {
    value = aws_kinesis_stream.data_stream.arn
}
