output "lambda_function_arn" {
  value = "${aws_lambda_function.sns_subscriber.arn}"
}

output "lambda_function_role" {
  value = "${aws_iam_role.lambda_exec.id}"
}
