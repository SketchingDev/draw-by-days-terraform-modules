output "lambda_function_arn" {
  value = "${aws_lambda_function.custom_function.arn}"
}

output "lambda_function_role" {
  value = "${aws_iam_role.lambda_exec.id}"
}
