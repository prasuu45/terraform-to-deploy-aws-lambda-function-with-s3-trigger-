# define the lambda function
resource "aws_lambda_function" "my_lambda_function" {
    function_name = "my_lambda_function"
    role = aws_iam_role.lambda_role.arn
    handler = "main.handler"
    runtime = "python3.11"
    timeout = 60
    memory_size = 128

    #use the archive data source to zip the code
    filename = data.archive_file.lambda_code.output_path
    source_code_hash = data.archive_file.lambda_code.output_base64sha256

    #define enviroment variables

    environment {
      variables = {
         "BUCKET_PATH" = "inbound-bucket-custome/incoming/"
      }
    }
}

#create a lambda extension role

# Define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
    name = "my-lambda-role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

##create an iam policy for s3 bucket access
resource "aws_iam_policy" "s3-bucket-policy" {
    name = "s3-bucket-policy"
    description = "allow read and write access to s3 bucket"
    policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::inbound-bucket-custome/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::inbound-bucket-custome"
        }
    ]
}
EOF
}
  
##Attach policy with the required permissions to the lambda execution role

# Attach the iam policy to lambda role

resource "aws_iam_role_policy_attachment" "lambda-aws_iam_role_policy_attachment" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.s3-bucket-policy.arn
  
}

##create an s3 trigger for the lambda function

#create an s3 bucket notiffication configuration

resource "aws_s3_bucket_notification" "lambda_trigger" {
    bucket = "hinata-online"
      lambda_function {
        lambda_function_arn = aws_lambda_function.my_lambda_function.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "incoming/"
    }
    depends_on = [ aws_lambda_permission.allow_s3_to_invoke_lambda ]
}
  

##lambda permissions s3 triger

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::hinata-online"
}

### crate a bucket policy that will allow lambda to get the bucket objects for the s3 notification trigger
## Attach the iam policy to the s3 bucket

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
    bucket = "hinata-online"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::hinata-online/*"
            }
        ]
    })
}