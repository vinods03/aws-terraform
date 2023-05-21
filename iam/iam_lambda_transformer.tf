resource "aws_iam_role" "lambda_transformer_role" {
  name = "lambda-transformer-role-381966"
  assume_role_policy  = data.aws_iam_policy_document.lambda_transformer_assume_role.json
  managed_policy_arns = [aws_iam_policy.lambda_transformer_policy.arn]
}

data "aws_iam_policy_document" "lambda_transformer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "lambda_transformer_policy" {
  name = "lambda-transformer-policy-381966"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:100163808729:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:100163808729:log-group:/aws/lambda/ordersTransformerFnNew:*"
            ]
        }
    ]
})
}



output "lambda_transformer_role_arn" {
  value = aws_iam_role.lambda_transformer_role.arn
}
