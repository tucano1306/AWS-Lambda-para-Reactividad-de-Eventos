provider "aws" {
  region = "us-east-1"  # Cambia esto a tu región preferida
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ec2_state_change" {
  function_name = "EC2StateChangeHandler"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  filename         = "lambda_function_payload.zip"

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "EC2StateChangeRule"
  description = "Captura cambios de estado en EC2"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["running", "stopped"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.ec2_state_change.name
  arn  = aws_lambda_function.ec2_state_change.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_state_change.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}