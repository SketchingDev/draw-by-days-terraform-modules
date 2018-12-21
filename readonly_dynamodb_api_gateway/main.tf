resource "aws_api_gateway_rest_api" "gateway" {
  name        = "${var.namespace}_gateway"
  description = "Rest API for invoking lambdas"
}

resource "aws_api_gateway_resource" "image" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "${var.query_path}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.image.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    "aws_api_gateway_method.proxy",
    "aws_api_gateway_integration.lambda"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "${var.stage_name}"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:us-east-1:dynamodb:action/Query"
  credentials             = "${aws_iam_role.get-sample.arn}"
  passthrough_behavior    =  "NEVER"

  request_templates = {
    "application/json" = "${var.request_template}"
  }
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.image.id}"
  http_method   = "${aws_api_gateway_method.proxy.http_method}"
  status_code   = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  depends_on = [
    "aws_api_gateway_integration.lambda"
  ]
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.image.id}"
  http_method   = "${aws_api_gateway_method.proxy.http_method}"
  status_code   = "${aws_api_gateway_method_response.200.status_code}"
}


resource "aws_iam_role" "get-sample" {
    name = "${var.namespace}_dynamodb_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dynamodb.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "2"
    }
  ]
}
EOF
}

data "template_file" "readonly_dynamodb_table" {
  template = "${file("${path.module}/readonly_dynamodb_table.tpl.json")}"

  vars {
    table_arn = "${var.table_arn}"
  }
}

resource "aws_iam_role_policy" "get-sample" {
    name = "${var.namespace}_get-sample"
    role = "${aws_iam_role.get-sample.id}"
    policy = "${data.template_file.readonly_dynamodb_table.rendered}"
}

resource "aws_iam_policy" "api_gateway_logging" {
  name = "${var.namespace}_api_gateway_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.get-sample.name}"
  policy_arn = "${aws_iam_policy.api_gateway_logging.arn}"
}
