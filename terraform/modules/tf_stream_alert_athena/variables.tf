variable "lambda_handler" {
  type    = "string"
  default = "main.handler"
}

variable "lambda_memory" {
  type    = "string"
  default = "128"
}

variable "lambda_timeout" {
  type    = "string"
  default = "60"
}

variable "lambda_s3_bucket" {
  type = "string"
}

variable "lambda_s3_key" {
  type = "string"
}

variable "athena_data_buckets" {
  type = "list"
}
