#!/bin/sh
BUCKET_NAME=$1
DIRECTORY=$2
shift 2
# Options are passed to mount-s3. Concatenate them from an array into a single string.
PASSED_OPTIONS=$*
mkdir -p ${DIRECTORY}
mount-s3 ${BUCKET_NAME} ${DIRECTORY} ${PASSED_OPTIONS}
