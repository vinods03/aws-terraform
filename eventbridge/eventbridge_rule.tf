resource "aws_cloudwatch_event_rule" "trigger_glue_workflow" {
  name  = "trigger-glue-workflow-rule"
  description = "Run glue workflow that has s3 staging crawler, s3 staging to redshift staging job and the final redshift job"

  event_pattern = jsonencode({
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["vinod-streaming-project-staging-bucket"]
    }
  }
})
}

resource "aws_cloudwatch_event_target" "glue_workflow" {
  rule      = aws_cloudwatch_event_rule.trigger_glue_workflow.name
  target_id = "redshift_processor"
  arn = "arn:aws:glue:us-east-1:100163808729:workflow/redshift_processor"
  role_arn = "arn:aws:iam::100163808729:role/service-role/Amazon_EventBridge_Invoke_Glue_770269552"
  
}


