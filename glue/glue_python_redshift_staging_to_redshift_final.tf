variable "redshift_staging_to_redshift_final_role" {
    type = string
}

resource "aws_cloudwatch_log_group" "glue_python_redshift_staging_to_redshift_final_log_group" {
    name = "glue_python_redshift_staging_to_redshift_final_log_group"
    retention_in_days = 1
}

resource "aws_glue_job" "glue_python_redshift_staging_to_redshift_final" {
    name = "glue_python_redshift_staging_to_redshift_final"
    role_arn = var.redshift_staging_to_redshift_final_role
    timeout = 5

    command {
        name = "pythonshell"
        script_location = "s3://aws-glue-assets-100163808729-us-east-1/scripts/glue_python_redshift_staging_to_redshift_final.py"
        python_version = 3.9
    }

    default_arguments = {
        "--job-language" = "python"
        "--job-bookmark-option" = "job-bookmark-enable"
        "--continuous-log-logGroup" = "aws_cloudwatch_log_group.glue_python_redshift_staging_to_redshift_final_log_group.name"
        "--TempDir" = "s3://aws-glue-assets-100163808729-us-east-1/temporary/"
        "--enable-spark-ui" = "true"
        "--spark-event-logs-path" = "s3://aws-glue-assets-100163808729-us-east-1/sparkHistoryLogs/"
        "--enable-continuous-cloudwatch-log" = "true"
        "--enable-continuous-log-filter" = "true"
        "--enable-metrics"                   = ""
        "--max_concurrent_runs" = 1
        "--max_retries" = 0
    }
}

output "glue_python_redshift_staging_to_redshift_final_job_arn" {
  value = aws_glue_job.glue_python_redshift_staging_to_redshift_final.arn
}
