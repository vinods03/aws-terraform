variable "role" {
    type = string
}

variable landing_area_queue_arn {
    type = string
}

data "archive_file" "zip_the_python_code" {
    type = "zip"
    source_dir = "${path.module}/python_function/"
    output_path = "${path.module}/python_function/lambda_landing_to_staging_trigger.zip"
}

resource "aws_lambda_function" "lambda_landing_to_staging_trigger" {
    filename = "${path.module}/python_function/lambda_landing_to_staging_trigger.zip"
    function_name = "ordersGlueSparkJobTriggerNew"
    handler = "ordersGlueSparkJobTriggerNew.lambda_handler"
    role = var.role
    runtime = "python3.9"
    timeout = 300
}

resource "aws_lambda_event_source_mapping" "landing_area_queue_source" {
    event_source_arn = var.landing_area_queue_arn
    function_name = aws_lambda_function.lambda_landing_to_staging_trigger.function_name
    batch_size = 100
    maximum_batching_window_in_seconds = 180
    enabled = true
}

output "landing_to_staging_trigger_fn_arn" {
    value = aws_lambda_function.lambda_landing_to_staging_trigger.arn
}