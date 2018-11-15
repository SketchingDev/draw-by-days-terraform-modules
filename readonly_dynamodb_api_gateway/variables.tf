variable "namespace" {}
variable "stage_name" {}
variable "query_path" {}
variable "table_arn" {}
variable "request_template" {}

variable "domain_name" {}

variable "map_domain_name" {
    description = "Allows domain mapping to be skipped."
    default = true
}
