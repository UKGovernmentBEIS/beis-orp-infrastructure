# Adding a sample Lambda to show how it's done

# Can be tested at the console using an appropriate object e.g.:
# {"body": "{\"email\": \"test@example.com\"}"}

module "aws_lambda" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "lambda-python-example"
  handler = "lambda1.validate"
  runtime = "python3.8"
  source_path = [
    "${path.module}/files/lambda/lambda1.py"
  ]
}

# This deploys a Lambda from an existing GitHub Release ZIP object

module "lambda_function_existing_package_from_remote_url" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda-existing-package-local"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = data.null_data_source.downloaded_package.outputs["filename"]
}
