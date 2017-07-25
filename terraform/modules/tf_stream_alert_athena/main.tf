// IAM Role: Lambda Execution Role
resource "aws_iam_role" "athena_partition_role" {
  name = "streamalert_athena_partition_refresh"

  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role_policy.json}"
}

// IAM Policy Doc: Generic Lambda trust relationship policy
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

// IAM Role Policy: Allow the Lambda function to execute Athena queries
// Ref: http://amzn.to/2vJqUAA
resource "aws_iam_role_policy" "athena_query_permissions" {
  name = "streamalert_athena_partition_refresh"
  role = "${aws_iam_role.athena_partition_role.id}"

  policy = "${data.aws_iam_policy_document.athena_query_policy.json}"
}

// IAM Policy Doc: Athena, CloudWatch, and S3 permissions
data "aws_iam_policy_document" "athena_query_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "athena:RunQuery",
      "athena:GetQueryExecution",
      "athena:GetQueryExecutions",
      "athena:GetQueryResults",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::aws-athena-query-results-*",
    ]
  }
}

// Lambda Function: Athena Parition Refresh
resource "aws_lambda_function" "athena_partition_refresh" {
  function_name = "streamalert_athena_partition_refresh"
  description   = "StreamAlert Athena Refresh"
  runtime       = "python2.7"
  role          = "${aws_iam_role.athena_partition_role.arn}"
  handler       = "${var.lambda_handler}"
  memory_size   = "${var.lambda_memory}"
  timeout       = "${var.lambda_timeout}"
  s3_bucket     = "${var.lambda_s3_bucket}"
  s3_key        = "${var.lambda_s3_key}"

  environment {
    variables = {
      LOGGER_LEVEL = "${var.lambda_log_level}"
    }
  }

  tags {
    Name = "StreamAlert"
  }
}

// Lambda Alias: Rule Processor Production
resource "aws_lambda_alias" "athena_partition_refresh_production" {
  name             = "production"
  description      = "Production StreamAlert Athena Parition Refresh Alias"
  function_name    = "${aws_lambda_function.streamalert_rule_processor.arn}"
  function_version = "${var.rule_processor_version}"
}

// Lambda Permission: Allow Athena data buckets to invoke Lambda
resource "aws_lambda_permission" "allow_s3_invocation" {
  count         = "${length(var.athena_data_buckets)}"
  statement_id  = "AthenaDataRefresh${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.athena_partition_refresh}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${lookup(var.athena_data_buckets, count.index}"
  qualifier     = "production"
}

// S3 Bucekt Notificaiton: Configure S3 to notify Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = "${length(var.athena_data_buckets)}"
  bucket = "${lookup(var.athena_data_buckets, count.index}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_alias.athena_partition_refresh_production.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
