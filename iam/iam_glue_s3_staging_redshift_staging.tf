resource "aws_iam_role" "glue_job_s3_staging_to_redshift_staging_role" {
    name = "glue-job-s3-staging-redshift-staging-role-381966"
    assume_role_policy = data.aws_iam_policy_document.glue_job_s3_staging_redshift_staging_assume_role.json
    managed_policy_arns = [aws_iam_policy.glue_job_s3_staging_redshift_staging_policy.arn]
}

data "aws_iam_policy_document" "glue_job_s3_staging_redshift_staging_assume_role" {
    statement {
        effect = "Allow"

        principals {
            type = "Service"
            identifiers = ["glue.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
  }

resource "aws_iam_policy" "glue_job_s3_staging_redshift_staging_policy" {
  name = "glue-job-s3-staging-redshift-staging-policy-381966"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
})
}

output "glue_job_s3_staging_redshift_staging_role_arn" {
    value = aws_iam_role.glue_job_s3_staging_to_redshift_staging_role.arn
}