# ========================= #
# == Event Hub Resources == #
# ========================= #
# Purpose
# To deploy an AWS Event Hub Cron Job to execute the Lambda function every day

resource "aws_cloudwatch_event_rule" "query_visitors_cron" {
  name                = "Query_visitors_cron_job"
  description         = "Query visitors cron job"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "delete_old_amis" {
  rule      = "${aws_cloudwatch_event_rule.query_visitors_cron.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.lambda_deploy.arn}"
}