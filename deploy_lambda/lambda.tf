# ========================== #
# = Lambda Function Deploy = #
# ========================== #
# Purpose
# Deploying Lambda function for the visitor notification system
# Includes a zipped file payload of the python code

resource "aws_lambda_function" "lambda_deploy" {
  filename      = "${path.module}/../lambda_function_payload.zip"
  function_name = "VisitorNotificationSystem"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filemd5("${path.module}/../lambda_function_payload.zip")

  runtime = "python3.9"
  timeout = 60
  environment {
    variables = {
      bucketname                  = var.log_bucket
      athena_db                   = aws_athena_database.alb_db.name
      athena_wg                   = aws_athena_workgroup.athena_wg.id
      athena_query_visitor_query  = aws_athena_named_query.visitor_query.query
      athena_query_table_create   = aws_athena_named_query.alb_logs_table.query
      ses_email                   = var.ses_email
    }
  }

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "VisitorNotificationSystem",
    })
  )}"
}

resource "aws_lambda_permission" "cw_call_visitor_query" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_deploy.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.query_visitors_cron.arn}"
}