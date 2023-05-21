variable "landing_to_staging_job_role" {
    type = string
}


resource "aws_cloudwatch_log_group" "glue_spark_landing_to_staging_log_group" {
  name  = "glue_spark_landing_to_staging_log_group"
  retention_in_days = 1
}

resource "aws_glue_job" "glue_spark_s3_landing_to_s3_staging" {
    name = "glue_spark_s3_landing_to_s3_staging"
    role_arn = var.landing_to_staging_job_role
    glue_version = "3.0"
    worker_type = "G.1X"
    number_of_workers = 2
    timeout = 5
    
    command {
        script_location = "s3://aws-glue-assets-100163808729-us-east-1/scripts/orders_processor_landing_to_staging_new.py"
    }

    default_arguments = {
    "--job-language" = "python"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--continuous-log-logGroup"  = "aws_cloudwatch_log_group.glue_spark_landing_to_staging_log_group.name"
    "--TempDir" = "s3://aws-glue-assets-100163808729-us-east-1/temporary/"
    "--enable-spark-ui" = "true"
    "--spark-event-logs-path" = "s3://aws-glue-assets-100163808729-us-east-1/sparkHistoryLogs/"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--max_concurrent_runs" = 1
    "--max_retries" = 0
    "--appName" = "orders_processor"
    "--tgt_bucket" = "s3://vinod-streaming-project-staging-bucket/"
    "--tgt_file_format" = "parquet"
  }

}

output "glue_s3_landing_to_s3_staging_job_arn" {
  value = aws_glue_job.glue_spark_s3_landing_to_s3_staging.arn
}
