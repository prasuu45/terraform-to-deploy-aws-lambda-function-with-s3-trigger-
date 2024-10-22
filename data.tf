## define the archive data source to zip the code

data "archive_file" "lambda_code" {
    type = "zip"
    source_dir = "lambda_function/"
    output_path = "lambda_code.zip"
  
}