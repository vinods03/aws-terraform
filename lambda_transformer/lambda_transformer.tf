variable role {
    type = string
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/python_function/"
output_path = "${path.module}/python_function/lambda_transformer.zip"
}

resource "aws_lambda_function" "lambda_transformer" {
    filename = "${path.module}/python_function/lambda_transformer.zip"
    function_name = "ordersTransformerFnNew"
    role = var.role
    handler = "ordersTransformerFnNew.lambda_handler"
    runtime = "python3.9"
    timeout = 300
}

output "transformer_fn_arn" {
    value = aws_lambda_function.lambda_transformer.arn
}
