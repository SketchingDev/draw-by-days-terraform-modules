variable "namespace" {}

variable "lambda_filename" {}
variable "lambda_handler" {}

variable "stage_name" {}

variable "domain_name" {}

variable "map_domain_name" {
    description = "Allows domain mapping to be skipped."
    default = true
}
