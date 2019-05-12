#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue
load bats-common

DOCKER_IMAGE="madworx/playground"

local_suite_setup() {
	 docker build -q -t "${DOCKER_IMAGE}:test-ecr" -f - . > /dev/null <<EOF
FROM busybox:latest
MAINTAINER "test ecr maint"
CMD [ "/bin/sh", "-c", "echo ok-output" ]
EOF
}

@test "Amazon ECR push should work" {
    (awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
}

@test "Amazon ECR push w/ non-existent local image should fail" {
    ! (awsecr_push_image "${DOCKER_IMAGE}:tadfasdfest-ecr")
}

@test "Amazon ECR without credentials should fail" {
    ! (unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION ; awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
    ! (unset AWS_DEFAULT_REGION ; awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
    ! (unset AWS_SECRET_ACCESS_KEY ; awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
    ! (unset AWS_ACCESS_KEY_ID; awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
}

@test "Amazon ECR push+pull+run should work" {
    FULL_PATH=$(awsecr_push_image "${DOCKER_IMAGE}:test-ecr") || false
    docker rmi "${FULL_PATH}" > /dev/null
    OUTPUT="$(docker run "${FULL_PATH}")" || false
    if [ "${OUTPUT}" != "ok-output" ] ; then
        echo "Unable to verify output from pulled image." 1>&2
        false
    fi
}

