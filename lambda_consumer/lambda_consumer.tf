variable role {
    type = string
}

variable kinesis_data_stream_arn {
    type = string
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/python_function/"
output_path = "${path.module}/python_function/lambda_consumer.zip"
}

resource "aws_lambda_function" "lambda_consumer" {
    filename = "${path.module}/python_function/lambda_consumer.zip"
    function_name = "ordersConsumerFnNew"
    role = var.role
    handler = "ordersConsumerFnNew.lambda_handler"
    runtime = "python3.9"
    timeout = 300
}

resource "aws_lambda_event_source_mapping" "kinesis_data_streams_source" {
  event_source_arn  = var.kinesis_data_stream_arn
  function_name     = aws_lambda_function.lambda_consumer.function_name
  starting_position = "LATEST"
  batch_size = 100
  maximum_batching_window_in_seconds = 30
  enabled = true
}


output "consumer_fn_arn" {
    value = aws_lambda_function.lambda_consumer.arn
}