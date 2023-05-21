resource "aws_iam_role" "firehose_role" {
  name = "firehose-role-381966"
  assume_role_policy  = data.aws_iam_policy_document.firehose_assume_role.json
  managed_policy_arns = [aws_iam_policy.firehose_policy.arn]
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "firehose_policy" {
  name = "firehose-policy-381966"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "kinesis:ListShards",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "s3:ListBucket",
                "kinesis:DescribeStream",
                "s3:GetBucketLocation",
                "logs:PutLogEvents",
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": [
                "arn:aws:s3:::vinod-streaming-project-bucket",
                "arn:aws:s3:::vinod-streaming-project-bucket/*",
                "arn:aws:kinesis:us-east-1:100163808729:stream/orders",
                "arn:aws:lambda:us-east-1:100163808729:function:*",
                "arn:aws:logs:us-east-1:100163808729:log-group:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%:log-stream:*",
                "arn:aws:logs:us-east-1:100163808729:log-group:/aws/kinesisfirehose/orders-delivery-stream:log-stream:*"
            ]
        }
    ]
})
}

output "firehose_role_arn" {
  value = aws_iam_role.firehose_role.arn
}



