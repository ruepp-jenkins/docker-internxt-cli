#!/bin/bash
set -e
echo "Starting build workflow"

scripts/docker_initialize.sh
. scripts/internxt-cli.sh

# run build
echo "[${BRANCH_NAME}] Building images: ${IMAGE_FULLNAME}"
if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]
then
    echo "Start ${BRANCH_NAME} build"
    docker buildx build \
        --build-arg INTERNXT_CLI_VERSION=${INTERNXT_CLI_VERSION} \
        --platform linux/amd64,linux/arm64 \
        -t ${IMAGE_FULLNAME}:${INTERNXT_CLI_VERSION} \
        -t ${IMAGE_FULLNAME}:latest \
        --pull \
        --push .
else
    echo "Start branch ${BRANCH_NAME} build"
    docker buildx build \
        --build-arg INTERNXT_CLI_VERSION=${INTERNXT_CLI_VERSION} \
        --platform linux/amd64,linux/arm64 \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME}-${INTERNXT_CLI_VERSION} \
        --pull \
        --push .
fi

# cleanup
scripts/docker_cleanup.sh
