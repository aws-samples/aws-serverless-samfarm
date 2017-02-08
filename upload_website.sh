#!/usr/bin/env bash

function usage {
     echo """
     This script is to upload the website components of the AWS Serverless Samfarm demo to the s3 bucket created to host
     the website. To use, pass the s3 bucket name after the script name.

     upload_website.sh <s3_bucket_name>

     ex:
     upload_website.sh samfarm-app-demo-app-bucket
     """
 }

S3_BUCKET=''

 # Get the table name
 if [ $# -eq 0 ]; then
     usage;
     exit;
 else
     S3_BUCKET="$1"
 fi

aws s3 cp ./website/ "s3://$S3_BUCKET" --recursive --exclude "*.yaml"
