#!/bin/bash
#
# This is a simple bash script to upload css and image files to a public AWS S3 bucket.
#
# eg: ./s3uploader.sh /home/s3uploads s3://public-bucket
#
# The script only uploads if:
# - the number of files in the folder has changed. The current filecount is written to a .filecounts file
# - the file does not exist in the S3 bucket
#
# NOTE: The script then set the image ACL to PUBLIC READ!!!!
#
# Supported files: css, jpg, jpeg, gif, bmp, svg - and does not check sub folders
#
# The credentials are read via the default AWS credential config

# read args from cli
S3BUCKET=${2%/}
LOCAL_FOLDER=${1%/}

# exit on first error
set -e

# ensure args end with a slash
S3BUCKET="$S3BUCKET"/
LOCAL_FOLDER="$LOCAL_FOLDER"/

# check if upload folder is set
if [[ "$LOCAL_FOLDER" == "/" ]];
then
	echo "Cache folder must be specified as an arg. Eg: ./s3uploader.sh /home/s3uploads s3://public-bucket"
	exit 1
fi

# check if upload folder is set
if [[ "$S3BUCKET" == "/" ]];
then
        echo "S3 Bucket must be specified as an arg. Eg: ./s3uploader.sh /home/s3uploads s3://public-bucket"
        exit 1
fi

# check if the aws cli has been installed
AWS_INSTALLED=$( which aws | wc -l)
if [[ $AWS_INSTALLED -eq 0 ]];
then
	echo "Please install the aws cli to proceed, and ensure the Bucket is configured."
	exit 1
fi

# check if the filecounts changed since last time
if [[ -f "$LOCAL_FOLDER"".filecount" ]]; 
then
	CUR_COUNT=$(ls $LOCAL_FOLDER | wc -l )
	OLD_COUNT=$(cat "$LOCAL_FOLDER"".filecount" )
else
        CUR_COUNT=$(ls $LOCAL_FOLDER | wc -l )
        OLD_COUNT=0
fi

if [[ "$OLD_COUNT" -eq "$CUR_COUNT" ]];
then
        echo "No file count changes!"
	#DEBUG: echo "Old count: [$OLD_COUNT] - Cur count: [$CUR_COUNT]"
	exit 0
else
        echo $CUR_COUNT > "$LOCAL_FOLDER"".filecount"
fi

# upload CSS and images
for f in $(find "$LOCAL_FOLDER" -name '*.css'-o -name "*.CSS" -o -name "*.jpg" -o -name "*.JPG" -o -name "*.jpeg" -o -name "*.JPEG" -o -name "*.gif" -o -name "*.GIF" -o -name "*.svg" -o -name "*.SVG" -o -name "*.png" -o -name "*.PNG" -o -name "*.bmp" -o -name "*.BMP" );
do
	FILE_NAME=$(basename "$f")
        #DEBUG: echo "$FILE_NAME"

	echo "Check if $S3BUCKET$FILE_NAME exists..."
	EXISTS=$(/bin/aws s3 ls "$S3BUCKET$FILE_NAME" | wc -l)
	if [ $EXISTS -eq 0 ];
	then
		echo " -> Does not exist, so upload."
		/bin/aws s3 cp "$f" $S3BUCKET --acl public-read
	else
		echo " -> Does exist, so ignore."
	fi
done

echo "Done"
