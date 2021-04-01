# Bash script to upload files to an AWS S3 bucket #

This is a simple bash script to upload css and image files to a public AWS S3 bucket.

Example:
```
./s3uploader.sh /home/s3uploads s3://public-bucket
```

The script only uploads if:
- the number of files in the folder has changed. The current filecount is written to a .filecounts file
- the file does not exist in the S3 bucket

NOTE: The script then set the image ACL to PUBLIC READ!!!!

Supported files: css, jpg, jpeg, gif, bmp, svg - and does not check sub folders

The credentials are read via the default AWS credential config

1. Download .sh script.

2. Make the script executable:

```
chmod +x s3uploader.sh
```

3. Make sure the AWS CLI is installed

4. Make sure you have the public AWS S3 bucket configured

5. Make sure you have AWS IAM credentials with access to the Bucket

6. Add the credentials to the AWS CLI using ./aws configure

7. Run the script:

```
s3uploader.sh /local-images-cache s3://public-images-cache
```

