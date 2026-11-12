terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
	region = "eu-north-1"
}

data "archive_file" "website" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda" {
  name = "iu-cloud-programming-p2-lambda"

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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "website" {
  function_name = "iu-cloud-programming-p2-website"
  runtime       = "python3.13"
  handler       = "handler.lambda_handler"
  role          = aws_iam_role.lambda.arn

  filename         = data.archive_file.website.output_path
  source_code_hash = data.archive_file.website.output_base64sha256
}

resource "aws_lambda_function_url" "website" {
  function_name      = aws_lambda_function.website.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_cloudfront_origin_access_control" "lambda" {
  name                              = "iu-cloud-programming-p2-lambda"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "website" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "website" {
  enabled = true

  origin {
    domain_name              = trimsuffix(trimprefix(aws_lambda_function_url.website.function_url, "https://"), "/")
    origin_id                = "lambda-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.lambda.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "lambda-website"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.website.id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_lambda_permission" "cloudfront_url" {
  statement_id           = "AllowCloudFrontURL"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.website.function_name
  principal              = "cloudfront.amazonaws.com"
  source_arn             = aws_cloudfront_distribution.website.arn
  function_url_auth_type = "AWS_IAM"
}

resource "aws_lambda_permission" "cloudfront_invoke" {
  statement_id             = "AllowCloudFrontInvoke"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.website.function_name
  principal                = "cloudfront.amazonaws.com"
  source_arn               = aws_cloudfront_distribution.website.arn
  invoked_via_function_url = true
}

output "website_url" {
  value = "https://${aws_cloudfront_distribution.website.domain_name}"
}