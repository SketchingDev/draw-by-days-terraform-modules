variable "sns_topic_arn" {
  description = "ARN for the SNS topic that will trigger the lambda"
}

variable "function_name" {
  description = "A unique name for the Lambda Function that will be invoked by the notification."
}

variable "function_filename" {
  description = "The path to the function's deployment package within the local filesystem"
}

variable "function_handler" {
  description = "The function entrypoint in your code for the Lambda Function."
  default = "main.handler"
}

variable "function_runtime" {
  default = "nodejs8.10"
}

variable "function_environment" {
  description = "The Lambda environment's configuration settings. Values live under 'variables' attribute"
  type        = "map"
  default     = {}
}

variable "sns_filter_policy" {
  description = "JSON String with the filter policy that will be used in the subscription to filter messages seen by the Lambda Function."
  default = ""
}
