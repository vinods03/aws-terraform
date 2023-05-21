provider "aws" {
    region = "us-east-1"
}

variable "env" {
    type = string
    description = "Which environment is this for ?"
}

variable "data_stream_name" {
    type = string
    default = "orders"
}

variable "delivery_stream_name" {
    type = string
    default = "orders-delivery-stream"
}

variable "landing-bucket-name" {
    type = string
    default = "vinod-streaming-project-bucket"
}

variable "staging-bucket-name" {
    type = string
    default = "vinod-streaming-project-staging-bucket"
}

module "iam" {
    source = "./iam"
}

module "kinesis-data-stream" {
    source = "./kinesis_data_stream"
    environment = var.env
    kinesis_data_stream_name = var.data_stream_name
}

module "kinesis-delivery-stream" {
    kinesis_delivery_stream_name = var.delivery_stream_name
    source = "./kinesis_delivery_stream"
    input_data_stream_arn = module.kinesis-data-stream.stream_arn
    output_s3_bucket_arn = module.s3-landing-area.s3_landing_bucket_arn
    lambda_transformer_fn = module.lambda-transformer-function.transformer_fn_arn
    role = module.iam.firehose_role_arn
    depends_on = [
      module.iam, module.kinesis-data-stream, module.s3-landing-area
    ]
}

module "s3-landing-area" {
    source = "./s3_landing_area"
    environment = var.env
    landing-bucket-name = var.landing-bucket-name
}

module "s3-staging-area" {
    source = "./s3_staging_area"
    environment = var.env
    staging-bucket-name = var.staging-bucket-name
}

module "lambda-consumer-function" {
    source = "./lambda_consumer"
    role = module.iam.lambda_consumer_role_arn
    kinesis_data_stream_arn = module.kinesis-data-stream.stream_arn
}

module "lambda-transformer-function" {
    source = "./lambda_transformer"
    role = module.iam.lambda_transformer_role_arn
}

module "lambda-landing-to-staging-trigger-function" {
    source = "./lambda_landing_to_staging_and_dynamodb_audit"
    role = module.iam.lambda_landing_to_staging_trigger_role_arn
    landing_area_queue_arn = module.s3-landing-area.s3_landing_bucket_queue_arn
}

module "glue" {
    source = "./glue"
    landing_to_staging_job_role = module.iam.glue_job_landing_to_staging_role_arn
    staging_crawler_role = module.iam.glue_crawler_staging_role_arn
    s3_staging_to_redshift_staging_job_role = module.iam.glue_job_s3_staging_redshift_staging_role_arn
    redshift_staging_to_redshift_final_role = module.iam.glue_job_redshift_staging_redshift_final_role_arn
}

module "eventbridge" {
    source = "./eventbridge"
}

output "data_stream_id" {
    value = module.kinesis-data-stream.stream_id
  
}

output "data_stream_arn" {
    value = module.kinesis-data-stream.stream_arn
}

output "delivery_stream_arn" {
    value = module.kinesis-delivery-stream.firehose_arn
}

output "s3_landing_bucket_arn" {
    value = module.s3-landing-area.s3_landing_bucket_arn
}

output "s3_staging_bucket_arn" {
    value = module.s3-staging-area.s3_staging_bucket_arn
}

output "s3_landing_bucket_queue_arn" {
    value = module.s3-landing-area.s3_landing_bucket_queue_arn
}

output "consumer_fn_arn" {
    value = module.lambda-consumer-function.consumer_fn_arn
}

output "transformer_fn_arn" {
    value = module.lambda-transformer-function.transformer_fn_arn
}

output "landing_to_staging_trigger_fn_arn" {
    value = module.lambda-landing-to-staging-trigger-function.landing_to_staging_trigger_fn_arn
}

output "s3_landing_to_s3_staging_glue_job_arn" {
    value = module.glue.glue_s3_landing_to_s3_staging_job_arn
}


output "staging_crawler_arn" {
    value = module.glue.glue_staging_crawler_arn
}

output "s3_staging_to_redshift_staging_glue_job_arn" {
    value = module.glue.glue_spark_s3_staging_to_redshift_staging_job_arn
}

output "redshift_staging_to_redshift_final_glue_job_arn" {
    value = module.glue.glue_python_redshift_staging_to_redshift_final_job_arn
}

output "glue_workflow_arn" {
    value = module.glue.glue_workflow_arn
}


