# terraform.tfvars
function_filename = "function.zip"
function_name = "my-lambda-function"
function_role_arn = "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/<YOUR_LAMBDA_ROLE_NAME>"
function_handler = "lambda_function.lambda_handler"
function_runtime = "python3.13"
