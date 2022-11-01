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
