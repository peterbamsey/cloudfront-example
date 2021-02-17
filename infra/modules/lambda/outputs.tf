output "lambda-arn" {
  value = "${aws_lambda_function.lambda.arn}:${aws_lambda_function.lambda.version}"
}