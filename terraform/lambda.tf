# IAM role that the Lambda function will use.
resource "aws_iam_role" "visitor_counter_lambda" {
  name = "resume-visitor-counter-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Allow the Lambda function to update the visitor counter table.
resource "aws_iam_role_policy" "visitor_counter_dynamodb" {
  name = "resume-visitor-counter-dynamodb-policy"
  role = aws_iam_role.visitor_counter_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:UpdateItem"
        ]

        Resource = aws_dynamodb_table.visitor_counter.arn
      }
    ]
  })
}

# Package the Python code into a ZIP file for Lambda.
data "archive_file" "visitor_counter_lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambda/visitor_counter.py"
  output_path = "${path.module}/visitor_counter.zip"
}


# Create the Lambda function.
resource "aws_lambda_function" "visitor_counter" {
  function_name = "resume-visitor-counter"

  filename         = data.archive_file.visitor_counter_lambda.output_path
  source_code_hash = data.archive_file.visitor_counter_lambda.output_base64sha256

  role = aws_iam_role.visitor_counter_lambda.arn

  handler = "visitor_counter.lambda_handler"
  runtime = "python3.13"

  timeout = 5
}