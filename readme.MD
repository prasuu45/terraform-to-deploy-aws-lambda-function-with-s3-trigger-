Scenario
---------
Our team receives numerous files from a third-party vendor, who uploads them to an S3 bucket. These files are suffixed with date stamps. Over time, we accumulated over a thousand files, which presented a challenge since S3 doesn’t allow sorting objects by date when there are over 1,000 objects.

Our team performs daily checks, downloading the current day’s file to process the information. However, they struggled to sort and locate the latest files efficiently. To address this issue, we developed a Lambda function that organizes files in a specific path into folders structured by year/month/day.

Implementation
---------------
I will use Terraform to provision the Lambda function.

I will use Python as Lambda runtime.

Python script will pick the files uploaded to a path and move them to their respective folder with year, month, and date.

S3 notification will trigger the Lambda (When any new files get uploaded to the bucket on a path)


Prerequisite:
-------------

Basic understanding of AWS services such as Lambda, S3, IAM, etc.

Basic understanding of Python and boto3 SDK

Basic knowledge of Terraform.
