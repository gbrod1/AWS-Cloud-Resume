# HTTP API that the resume website will call.
resource "aws_apigatewayv2_api" "visitor_counter" {
  name          = "resume-visitor-counter-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "https://gloriabrodrick.com",
      "https://www.gloriabrodrick.com"
    ]

    allow_methods = [
      "GET"
    ]

    allow_headers = [
      "content-type"
    ]
  }
}

# Connect API Gateway to the Lambda function.
resource "aws_apigatewayv2_integration" "visitor_counter" {
  api_id = aws_apigatewayv2_api.visitor_counter.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visitor_counter.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Create the public GET /visitors route.
resource "aws_apigatewayv2_route" "visitor_counter" {
  api_id = aws_apigatewayv2_api.visitor_counter.id

  route_key = "GET /visitors"

  target = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}


# Create the default API stage and deploy changes automatically.
resource "aws_apigatewayv2_stage" "visitor_counter" {
  api_id = aws_apigatewayv2_api.visitor_counter.id

  name        = "$default"
  auto_deploy = true
}


# Allow API Gateway to invoke the Lambda function.
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.visitor_counter.execution_arn}/*/*"
}