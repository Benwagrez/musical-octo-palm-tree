variable "log_bucket" {
	type = string
	default = ""
}

variable "log_bucket_location" {
	type = string
	default = ""
}

variable "common_tags" {
  type = map(string)
  description = "Commong tags to provision on resources created in Terraform"
  default = {
		Infra = "Lambda_Visitor_Query",
		Owner = "benwagrez@gmail.com"
  }
}

variable "athena_table_name" {
	type = string
	default = "alb_logs"
}

variable "ses_email" {
	type = string
}