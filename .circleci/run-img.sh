#!/bin/bash

REPO_NAME="shopware"

if [ $# -lt 3 ]; then
  echo "Usage: $0 <CIRCLE_CI_TOKEN> <IMAGE_NAME> <IMAGE_TAG> <IS_LATEST> "
  exit 1
fi

TOKEN=$1
IMAGE_NAME=$2
IMAGE_TAG=$3
IS_LATEST=$4

cat <<EOT > body.json
{
  "parameters": {
    "imageName": "$IMAGE_NAME",
    "imageTag": "$IMAGE_TAG",
    "setLatest": $IS_LATEST
  }
}
EOT

cat body.json

curl -X POST -d @body.json \
     -H "Content-Type: application/json" \
     -H "Circle-Token: $TOKEN" \
     "https://circleci.com/api/v2/project/github/dockware/$REPO_NAME/pipeline"

rm -rf body.json