variable "log_bucket" {
    type = string
    default = ""
}

variable "log_bucket_location" {
    type = string
    default = ""
}

variable "AWS_ACCESS_KEY" {
    type = string
}

variable "AWS_SECRET_KEY" {
    type = string
}

variable "athena_table_name" {
	type = string
}

variable "ses_email" {
    type = string
}

variable "region" {
    type = string
}