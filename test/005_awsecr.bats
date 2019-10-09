#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

DOCKER_IMAGE="madworx/playground"

if ! docker inspect "${DOCKER_IMAGE}:test-ecr" > /dev/null 2>&1 ; then
    docker build -t "${DOCKER_IMAGE}:test-ecr" - \
        < <(echo -e 'FROM busybox:latest\nMAINTAINER "test ecr maint\nCMD [ "/bin/sh", "-c", "echo ok-output" ]') > /tmp/docker.debug.log 2>&1
fi

@test "Amazon ECR push without awscli should fail" {
    !(PATH="" AWS_ACCESS_KEY_ID=adfkjahhs AWS_SECRET_ACCESS_KEY=adfkjahhs AWS_DEFAULT_REGION=eu-north-1 awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
}

@test "Amazon ECR push with invalid secrets should fail" {
    ! (AWS_ACCESS_KEY_ID=adfkjahhs awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
    ! (AWS_SECRET_ACCESS_KEY=adfkjahhs awsecr_push_image "${DOCKER_IMAGE}:test-ecr")
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

@test "Amazon ECR login+pull+run should work" {
    REPO_PATH=$(awsecr_login) || false
    FULL_PATH="${REPO_PATH}/${DOCKER_IMAGE}:test-ecr"
    docker rmi "${FULL_PATH}" > /dev/null
    OUTPUT="$(docker run "${FULL_PATH}")" || false
    if [ "${OUTPUT}" != "ok-output" ] ; then
        echo "Unable to verify output from pulled image." 1>&2
        false
    fi
}

