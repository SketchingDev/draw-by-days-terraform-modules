resource "aws_lambda_function" "custom_function" {
  function_name = "${var.function_name}"
  handler = "${var.function_handler}"
  runtime = "${var.function_runtime}"
  filename = "${var.function_filename}"
  source_code_hash = "${base64sha256(file(var.function_filename))}"
  role = "${aws_iam_role.lambda_exec.arn}"
  environment = ["${slice( list(var.function_environment), 0, length(var.function_environment) == 0 ? 0 : 1 )}"]
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_permission" "allow_process_invoker" {
  statement_id   = "AllowExecutionFromProcessInvoker"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.custom_function.function_name}"
  principal      = "lambda.amazonaws.com"
}

resource "aws_iam_role" "lambda_exec" {
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

resource "aws_cloudwatch_log_group" "sns_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.custom_function.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "xray_write_access" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}
