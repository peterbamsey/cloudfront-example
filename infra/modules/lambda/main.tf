locals {
  function-name = "${var.environment}-${var.function-name}"

  lambda-runtime           = "python3.8"
  lambda-timeout           = 30
  lambda-source-hash       = filebase64sha256("${path.module}/source/${var.function-name}/${var.function-name}.py")
  lambda-requirements-hash = filebase64sha256("${path.module}/source/${var.function-name}/${var.function-name}.py")
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.zip-file.output_path
  function_name    = local.function-name
  handler          = "${var.function-name}.lambda_handler"
  role             = aws_iam_role.role.arn
  runtime          = local.lambda-runtime
  source_code_hash = data.archive_file.zip-file.output_base64sha256
  timeout          = local.lambda-timeout

  environment {
    ENVIRONMENT     = var.environment
    FALLBACK-DOMAIN = var.fallback-domain
  }
}

resource "null_resource" "pip" {
  triggers {
    source        = local.lambda-source-hash
    reqruirements = local.lambda-requirements-hash
  }

  provisioner "local-exec" {
    command = "cd ${path.module}; make build}"
  }
}

data "archive_file" "zip-file" {
  depends_on = [
    null_resource.pip
  ]

  output_path = "${path.module}/${var.function-name}.zip"
  source_dir  = "${path.module}/build/${var.function-name}"
  type        = "zip"
}

resource "aws_iam_role" "role" {
  name = local.function-name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "LamdaAssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "policy" {
  name = local.function-name
  role = aws_iam_role.role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:${var.region}:${var.account-id}:*"
      },
    ]
  })
}