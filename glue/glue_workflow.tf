resource "aws_glue_workflow" "glue_workflow" {
    name = "redshift_processor"
}

resource "aws_glue_trigger" "glue-workflow-start" {
  name = "trigger-start"
  type = "EVENT"
  workflow_name = aws_glue_workflow.glue_workflow.name

  actions {
    crawler_name = "orders_staging_crawler_new"
  }
}

resource "aws_glue_trigger" "glue-job-1-start" {
  name = "trigger-job-1"
  type  = "CONDITIONAL"
  workflow_name = aws_glue_workflow.glue_workflow.name

  predicate {
    conditions {
      crawler_name = "orders_staging_crawler_new"
      crawl_state    = "SUCCEEDED"
    }
  }

  actions {
    job_name = "glue_spark_s3_staging_to_redshift_staging"
  }
}

resource "aws_glue_trigger" "glue-job-2-start" {
  name = "trigger-job-2"
  type  = "CONDITIONAL"
  workflow_name = aws_glue_workflow.glue_workflow.name

  predicate {
    conditions {
      job_name = "glue_spark_s3_staging_to_redshift_staging"
      state    = "SUCCEEDED"
    }
  }

  actions {
    job_name = "glue_python_redshift_staging_to_redshift_final"
  }
}

output "glue_workflow_arn" {
  value = aws_glue_workflow.glue_workflow.arn
}