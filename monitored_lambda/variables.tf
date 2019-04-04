variable "namespace" {
  description = "Namespace prefixed to the names of resources"
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
