#!/bin/bash
# Rebuild script
# This is meant to be run on a regular basis to make sure everything works with
# the latest version of scripts.

set -e

# Test first
./test.sh

CREDENTIALS="$HOME/.dcycle-docker-credentials.sh"

if [ ! -f "$CREDENTIALS" ]; then
  echo "Please create $CREDENTIALS and add to it:"
  echo "DOCKERHUBUSER=xxx"
  echo "DOCKERHUBPASS=xxx"
  exit;
else
  source "$CREDENTIALS";
fi

PROJECT=compresspdf
DATE=`date '+%Y-%m-%d-%H-%M-%S-%Z'`
MAJORVERSION='2'
VERSION='2.0'

./test.sh

PROJECT=compresspdf
DATE=`date '+%Y-%m-%d-%H-%M-%S-%Z'`
MAJORVERSION='3'
VERSION='3.0'

# See https://github.com/dcycle/prepare-docker-buildx, for M1 native images.
git clone https://github.com/dcycle/prepare-docker-buildx.git
cd prepare-docker-buildx
export DOCKER_CLI_EXPERIMENTAL=enabled
./scripts/run.sh
cd ..

docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
docker login -u"$DOCKERHUBUSER" -p"$DOCKERHUBPASS"

# Start by getting the latest version of the official drupal image
docker pull alpine
# Rebuild the entire thing
docker buildx build -t dcycle/"$PROJECT":"$VERSION" --platform linux/amd64,linux/arm64/v8 --push .
docker buildx build -t dcycle/"$PROJECT":"$MAJORVERSION" --platform linux/amd64,linux/arm64/v8 --push .
docker buildx build -t dcycle/"$PROJECT":"$MAJORVERSION".$DATE --platform linux/amd64,linux/arm64/v8 --push .
docker buildx build -t dcycle/"$PROJECT":"$VERSION".$DATE --platform linux/amd64,linux/arm64/v8 --push .
# No longer using the latest tag, use the major version tag instead.
