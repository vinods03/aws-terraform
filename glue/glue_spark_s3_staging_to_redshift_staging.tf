variable "s3_staging_to_redshift_staging_job_role" {
    type = string
}

resource "aws_glue_connection" "ecommerce-redshift-cluster-connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://ecommerce-redshift-cluster.cal5w1bhifg1.us-east-1.redshift.amazonaws.com:5439/dev"
    PASSWORD            = "Test1234"
    USERNAME            = "awsuser"
  }

  name = "ecommerce-redshift-cluster-connection-new"

  physical_connection_requirements {
     availability_zone = "us-east-1e"
     subnet_id = "subnet-006d417e0769d0d1f"
     security_group_id_list = ["sg-0a1b7129938aacc3f"]
  }
}

resource "aws_glue_job" "glue_spark_s3_staging_to_redshift_staging" {
    name = "glue_spark_s3_staging_to_redshift_staging"
    role_arn = var.s3_staging_to_redshift_staging_job_role
    connections = [aws_glue_connection.ecommerce-redshift-cluster-connection.name]
    glue_version = "3.0"
    worker_type = "G.1X"
    number_of_workers = 2
    timeout = 5

    command {
        script_location = "s3://aws-glue-assets-100163808729-us-east-1/scripts/glue_spark_etl_orders_data_into_redshift_new.py"
    }

    default_arguments = {
    "--job-language" = "python"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--continuous-log-logGroup"  = "aws_cloudwatch_log_group.glue_spark_s3_staging_to_redshift_staging_new_log_group.name"
    "--TempDir" = "s3://aws-glue-assets-100163808729-us-east-1/temporary/"
    "--enable-spark-ui" = "true"
    "--spark-event-logs-path" = "s3://aws-glue-assets-100163808729-us-east-1/sparkHistoryLogs/"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
    "--max_concurrent_runs" = 1
    "--max_retries" = 0
  }
}

output "glue_spark_s3_staging_to_redshift_staging_job_arn" {
  value = aws_glue_job.glue_spark_s3_staging_to_redshift_staging.arn
}