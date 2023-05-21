variable "role" {
  type = string
}

variable "kinesis_delivery_stream_name" {
    type = string
}

variable "input_data_stream_arn" {
  type = string
}

variable "output_s3_bucket_arn" {
  type = string
}

variable "lambda_transformer_fn" {
  type = string
}

resource "aws_kinesis_firehose_delivery_stream" "data_firehose" {
  name = var.kinesis_delivery_stream_name
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.input_data_stream_arn
    role_arn = var.role
  }

  extended_s3_configuration {
    bucket_arn = var.output_s3_bucket_arn
    role_arn = var.role
    # role_arn   = aws_iam_role.firehose_role.arn
    # bucket_arn = aws_s3_bucket.bucket.arn

    buffer_size = 64
    buffer_interval = 60

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = var.lambda_transformer_fn
        # parameter_value = "arn:aws:lambda:us-east-1:100163808729:function:ordersTransformerFn:$LATEST"
        # parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }

     processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{order_id:.order_id}"
        }
      }

    }

    dynamic_partitioning_configuration {
      enabled = "true"
    }

    prefix              = "orders/order_id_!{partitionKeyFromQuery:order_id}"
    error_output_prefix = "order-errors"
  }
}


output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.data_firehose.arn
}
