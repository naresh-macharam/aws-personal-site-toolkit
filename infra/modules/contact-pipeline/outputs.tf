output "invoke_url" {
  description = "Full endpoint URL — put this in your homepage's CONTACT_ENDPOINT and your Hugo hugo.yaml's commentEndpoint"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}contact"
}

output "lambda_function_name" {
  value = aws_lambda_function.contact_handler.function_name
}

output "sender_verification_note" {
  value = "Check the inbox for ${var.sender_email} and click the SES verification link before testing — this step can't be automated."
}
