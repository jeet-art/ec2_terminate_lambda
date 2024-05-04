# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name               = "terminate_ec2_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Lambda Role (Example policy, adjust as needed)
resource "aws_iam_policy" "lambda_policy" {
  name        = "terminate_ec2_policy"
  description = "IAM policy for Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstanceAttribute"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.terminate_ec2_lambda.arn
      },
      {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-southeast-2:905418002740:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-southeast-2:905418002740:log-group:/aws/lambda/terminate_ec2_lambda:*"
            ]
        }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Lambda Function
resource "aws_lambda_function" "terminate_ec2_lambda" {
  function_name    = "terminate_ec2_lambda"
  filename         = "terminate_ec2_code.zip"  # Path to your Lambda function code
  source_code_hash = filebase64sha256("terminate_ec2_code.zip")  # Corrected source code hash
  role             = aws_iam_role.lambda_role.arn
  handler          = "terminate_ec2_code.lambda_handler"  # Change to your handler function
  runtime          = "python3.12"    # Change to your desired runtime
}

# CloudWatch Events Rule (Cron Trigger)
resource "aws_cloudwatch_event_rule" "terminate_ec2_trigger" {
  name                = "terminate_ec2_trigger"
  schedule_expression = "cron(*/5 * * * ? *)"  # Example: Run every 5 minutes
  
  tags = {
    Environment = "Production"
  }
}

# CloudWatch Events Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.terminate_ec2_trigger.name
  target_id = "terminate_ec2_lambda_target"
  arn       = aws_lambda_function.terminate_ec2_lambda.arn
}
