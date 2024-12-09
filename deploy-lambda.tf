data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
 
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
 
    actions = ["sts:AssumeRole"]
  }
} 
 
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "function.zip"
  function_name = "greeting-timestamp-lambda_3_tf"
  role          = "arn:aws:iam::050446384457:role/service-role/greeting-timestamp-lambda-role-0jr1suml"
  handler       = "lambda_function.lambda_handler"
 
  source_code_hash = filebase64sha256("function.zip")
 
  runtime = "python3.13"  
}
