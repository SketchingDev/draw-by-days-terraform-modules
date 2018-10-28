resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
}

output "validation-options" {
  value = "${aws_acm_certificate.cert.domain_validation_options}"
}

resource "aws_api_gateway_domain_name" "example" {
  domain_name = "${var.domain_name}"
  certificate_arn = "${aws_acm_certificate.cert.arn}"
}

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
