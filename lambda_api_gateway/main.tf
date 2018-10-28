resource "aws_api_gateway_rest_api" "gateway" {
  name        = "${var.namespace}_gateway"
  description = "Rest API for invoking lambdas"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "${var.stage_name}"
}

resource "aws_lambda_function" "gateway_lambda" {
  function_name = "${var.namespace}_lambda"
  filename = "${var.lambda_filename}"
  source_code_hash = "${base64sha256(file("${var.lambda_filename}"))}"

  handler = "${var.lambda_handler}"
  runtime = "nodejs8.10"

  role = "${aws_iam_role.gateway_lambda_role.arn}"
}

resource "aws_iam_role" "gateway_lambda_role" {
  name  = "${var.namespace}_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.gateway_lambda.invoke_arn}"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.gateway_lambda.invoke_arn}"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
}

output "validation-options" {
  value = "${aws_acm_certificate.cert.domain_validation_options}"
}

# resource "aws_route53_record" "cert-valid" {
#   zone_id = "${var.domain_zone_id}"
#   name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
#   type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
#   records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
#   ttl     = "3600"
# }

resource "aws_api_gateway_domain_name" "example" {
  domain_name = "${var.domain_name}"
  certificate_arn = "${aws_acm_certificate.cert.arn}"
}


# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "example" {
  zone_id = "${var.domain_zone_id}" # See aws_route53_zone for how to create this

  name = "${aws_api_gateway_domain_name.example.domain_name}"
  type = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.example.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.example.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}











resource "aws_api_gateway_base_path_mapping" "test" {
  api_id      = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "${aws_api_gateway_deployment.gateway_deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.example.domain_name}"
}

# resource "aws_api_gateway_domain_name" "apitest" {
#   depends_on  = ["aws_route53_record.cert-valid"]
#   domain_name = "apitest.giancarlopetrini.com"

#   certificate_arn = "${aws_acm_certificate.cert.arn}"
# }

# resource "aws_route53_record" "apitest" {
#   zone_id = "${var.domain_zone_id}" # See aws_route53_zone for how to create this

#   name = "${aws_api_gateway_domain_name.apitest.domain_name}"
#   type = "A"

#   alias {
#     name                   = "${aws_api_gateway_domain_name.apitest.cloudfront_domain_name}"
#     zone_id                = "${aws_api_gateway_domain_name.apitest.cloudfront_zone_id}"
#     evaluate_target_health = true
#   }
# }


resource "aws_lambda_permission" "apigw" {
  statement_id  = "${var.namespace}_allow_api_invoke_lambda"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.gateway_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource within the API Gateway "REST API"
  source_arn = "${aws_api_gateway_deployment.gateway_deployment.execution_arn}/*/*"
}
