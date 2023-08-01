import boto3
from botocore.exceptions import NoCredentialsError

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = '<your_bucket_name>'

    try:
        # Get the list of objects in the bucket
        objs = s3.list_objects_v2(Bucket=bucket_name)['Contents']
        # Find the latest file
        latest_file = max(objs, key=lambda x: x['LastModified'])
        # Generate the pre-signed URL
        response = s3.generate_presigned_url('get_object',
                                             Params={'Bucket': bucket_name, 'Key': latest_file['Key']},
                                             ExpiresIn=900)
    except NoCredentialsError:
        response = 'No AWS credentials found'
    except Exception as e:
        response = 'Error occurred: ' + str(e)
    return response
