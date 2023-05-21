resource "aws_iam_role" "glue_job_redshift_staging_redshift_final_role" {
    name = "glue-job-redshift-staging-redshift-final-role-381966"
    assume_role_policy = data.aws_iam_policy_document.glue_job_redshift_staging_redshift_final_assume_role.json
    managed_policy_arns = [aws_iam_policy.glue_job_redshift_staging_redshift_final_policy.arn]
}

data "aws_iam_policy_document" "glue_job_redshift_staging_redshift_final_assume_role" {
    statement {
        effect = "Allow"

    principals {
        type = "Service"
        identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    
  }
}

resource "aws_iam_policy" "glue_job_redshift_staging_redshift_final_policy" {
    name = "glue-job-redshift-staging-redshift-final-policy-381966"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "*",
                    "Resource": "*"
                }
            ]
        }
    )
}

output "glue_job_redshift_staging_redshift_final_role_arn" {
    value = aws_iam_role.glue_job_redshift_staging_redshift_final_role.arn
}