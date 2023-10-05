# ========================= #
# === Athena Resources ==== #
# ========================= #
# Purpose
# To deploy an Athena database to receive 
# To stage queries to build alb table and query visitors

resource "aws_athena_database" "alb_db" {
  name   = "alb_database"
  bucket = var.log_bucket
}

# Include the code used to partition the database / table 

resource "aws_athena_workgroup" "athena_wg" {
  name = "alb_default_workgroup"

  configuration {
    result_configuration {
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_athena_named_query" "alb_logs_table" {
  name      = "Create alb_logs Table"
  workgroup = aws_athena_workgroup.athena_wg.id
  database  = aws_athena_database.alb_db.name
  query     = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS alb_logs_table (type string, time string, elb string, client_ip string, client_port int, target_ip string, target_port int, request_processing_time double, target_processing_time double, response_processing_time double, elb_status_code int, target_status_code string, received_bytes bigint, sent_bytes bigint, request_verb string, request_url string, request_proto string, user_agent string, ssl_cipher string, ssl_protocol string, target_group_arn string, trace_id string, domain_name string, chosen_cert_arn string, matched_rule_priority string, request_creation_time string, actions_executed string, redirect_url string, lambda_error_reason string, target_port_list string, target_status_code_list string, classification string, classification_reason string) PARTITIONED BY (day STRING) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe' WITH SERDEPROPERTIES ( 'serialization.format' = '1', 'input.regex' = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) (.*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-_]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^ ]*)\" \"([^\s]+?)\" \"([^\s]+)\" \"([^ ]*)\" \"([^ ]*)\"') LOCATION 's3://${var.log_bucket}${var.log_bucket_location}' TBLPROPERTIES ( "projection.enabled" = "true", "projection.day.type" = "date", "projection.day.range" = "2023/09/01,NOW", "projection.day.format" = "yyyy/MM/dd", "projection.day.interval" = "1", "projection.day.interval.unit" = "DAYS", "storage.location.template" = "s3://${var.log_bucket}${var.log_bucket_location}$${day}")
EOF
}

resource "aws_athena_named_query" "visitor_query" {
  name      = "Visitor query"
  workgroup = aws_athena_workgroup.athena_wg.id
  database  = aws_athena_database.alb_db.name
  query     = <<EOF
SELECT distinct client_ip, count() as count from alb_logs WHERE (parse_datetime(time,'yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z') >= date_add('day', -1, current_timestamp)) GROUP by client_ip ORDER by count() DESC;
EOF
}