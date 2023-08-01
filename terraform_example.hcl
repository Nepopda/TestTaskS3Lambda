provider "aws" {
  region = "us-west-2"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::my-bucket"]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::my-bucket/*"]
  }
}

resource "aws_iam_role" "s3_role" {
  name = "S3Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "s3_function" {
  function_name    = "S3Function"
  s3_bucket        = "my-bucket"
  s3_key           = "lambda_function_payload.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.s3_role.arn
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

resource "aws_lambda_permission" "s3_invocation" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::my-bucket"
}
