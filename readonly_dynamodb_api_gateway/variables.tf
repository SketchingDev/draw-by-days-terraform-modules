variable "namespace" {
    description = "Namespace used as a prefix when naming resources"
}

variable "root_path" {
    description = "The first path segmant used to address the endpoint .e.g. domain.com/<root_path>"
}

variable "path_part" {
    description = "The last path segment of this API resource"
}

variable "table_arn" {
    description = "ARN of the DynamoDB this API will interact with"
}
variable "request_template" {
    description = "Template used to tranform request to DynamoDB query"
}

variable "domain_name" {
    description = "Domain name that API will use"
}

variable "map_domain_name" {
    description = "Allows domain mapping to be skipped"
    default = true
}
