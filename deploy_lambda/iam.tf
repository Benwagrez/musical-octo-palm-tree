# ========================= #
# ===== IAM resources ===== #
# ========================= #
# Purpose
# Deploying IAM resources to allow Lambda to execute actions on an S3 bucket and Athena

# Reference iam policy for sts:AssumeRole to attach to Lambda IAM role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM role for Lambda funtion
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Created S3 & Athena access Policy for IAM Role
resource "aws_iam_policy" "policy" {
  name = "LambdaS3AthenaAccessPolicy"
  description = "Access policy granting Lambda access to S3 bucket where athena outputs will be stored and Amazon Athena."

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"logs:*"
			],
			"Resource": "arn:aws:logs:*:*:*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:ListObjects",
				"s3:ListBucket",
				"s3:ListAllMyBuckets",
				"s3:GetObjectAttributes"
			],
			"Resource": [ "arn:aws:s3:::${var.log_bucket}/*", "arn:aws:s3:::${var.log_bucket}" ]
		},
		{
			"Effect": "Allow",
			"Action": [
					"glue:CreateDatabase",
					"glue:DeleteDatabase",
					"glue:GetDatabase",
					"glue:GetDatabases",
					"glue:UpdateDatabase",
					"glue:CreateTable",
					"glue:DeleteTable",
					"glue:BatchDeleteTable",
					"glue:UpdateTable",
					"glue:GetTable",
					"glue:GetTables",
					"glue:BatchCreatePartition",
					"glue:CreatePartition",
					"glue:DeletePartition",
					"glue:BatchDeletePartition",
					"glue:UpdatePartition",
					"glue:GetPartition",
					"glue:GetPartitions",
					"glue:BatchGetPartition"
			],
			"Resource": [
					"*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetBucketLocation"
			],
			"Resource": "arn:aws:s3:::*"
		},
		{
			"Effect": "Allow",
			"Action": [
					"glue:CreateDatabase",
					"glue:DeleteDatabase",
					"glue:GetDatabase",
					"glue:GetDatabases",
					"glue:UpdateDatabase",
					"glue:CreateTable",
					"glue:DeleteTable",
					"glue:BatchDeleteTable",
					"glue:UpdateTable",
					"glue:GetTable",
					"glue:GetTables",
					"glue:BatchCreatePartition",
					"glue:CreatePartition",
					"glue:DeletePartition",
					"glue:BatchDeletePartition",
					"glue:UpdatePartition",
					"glue:GetPartition",
					"glue:GetPartitions",
					"glue:BatchGetPartition"
			],
			"Resource": [
					"*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"athena:StartQueryExecution",
				"athena:GetWorkGroup",
				"athena:ListDatabases",
				"athena:StopQueryExecution",
				"athena:GetQueryExecution",
				"athena:GetQueryResults",
				"athena:GetDatabase",
				"athena:GetDataCatalog",
				"athena:ListQueryExecutions"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
					"ses:SendEmail",
					"ses:SendRawEmail",
					"sns:ListTopics",
					"sns:GetTopicAttributes"
			],
			"Resource": "*"
		}
	]
} 
	EOF
}

# Attaching iam role to lambda action policy
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}