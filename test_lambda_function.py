import boto3
import pytest
from moto import mock_s3
from lambda_function import lambda_handler

@mock_s3
def test_lambda_handler():
    # Set up the mock S3
    conn = boto3.resource('s3', region_name='us-east-1')
    conn.create_bucket(Bucket='my-bucket')
    
    # Add a test file to the bucket
    conn.Object('my-bucket', 'test.txt').put(Body='This is test data')

    # Run the lambda handler
    response = lambda_handler(None, None)

    # Verify the pre-signed URL points to the correct S3 object
    assert 'https://my-bucket.s3.amazonaws.com/test.txt' in response
