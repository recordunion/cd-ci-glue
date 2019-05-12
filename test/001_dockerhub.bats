#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

DOCKER_IMAGE="madworx/playground"

docker build -q -t "${DOCKER_IMAGE}:cdci-test" - > /dev/null <<EOF
FROM scratch
MAINTAINER "dummy"
EOF

@test "DockerHub down should fail" {
    _DOCKERHUB_URL="http://localhost"
    run dockerhub_set_description "${DOCKER_IMAGE}" <(echo "Last tested: $(date)")
    [ "$status" -eq 1 ]
}

@test "DockerHub description update w/ incorrect credentials should fail" {
    DOCKER_PASSWORD=incorrectpassword
    run dockerhub_set_description "${DOCKER_IMAGE}" <(echo "Last tested: $(date)")
    [ "$status" -eq 1 ]
}

@test "DockerHub operations without credentials should fail" {
    unset DOCKER_USERNAME
    unset DOCKER_PASSWORD
    ! (dockerhub_push_image)
    ! (dockerhub_set_description "${DOCKER_IMAGE}" $0)
    ! (dockerhub_set_description "${DOCKER_IMAGE}")
    ! (dockerhub_set_description)
    ! (dockerhub_push_image "${DOCKER_IMAGE}:cdci-test")
}

@test "DockerHub description update should work" {
    (dockerhub_set_description "${DOCKER_IMAGE}" <(echo "cd-ci-glue last tested: $(date)"))
}

@test "DockerHub description with non-existent file should fail" {
    ! (dockerhub_set_description "${DOCKER_IMAGE}" /non-existent)
}

@test "DockerHub description with unreadable file should fail" {
    TMPF="$(mktemp)"
    echo "test" > "${TMPF}"
    chmod 000 "${TMPF}"
    ! (dockerhub_set_description "${DOCKER_IMAGE}" "${TMPF}")
    rm -f "${TMPF}"
}

@test "DockerHub description with directory should fail" {
    ! (dockerhub_set_description "${DOCKER_IMAGE}" "/tmp")
}

@test "DockerHub image push should work" {
    (dockerhub_push_image "${DOCKER_IMAGE}:cdci-test")
}

@test "DockerHub image push w/ valid image but invalid credentials should fail" {
    (
        unset DOCKER_USERNAME
        !(dockerhub_push_image "${DOCKER_IMAGE}:cdci-test")
    )
    (
        unset DOCKER_PASSWORD
        !(dockerhub_push_image "${DOCKER_IMAGE}:cdci-test")
    )
    (
        unset DOCKER_USERNAME
        unset DOCKER_PASSWORD
        !(dockerhub_push_image "${DOCKER_IMAGE}:cdci-test")
    )
}

@test "DockerHub image push of non-existent image should fail" {
    ! (dockerhub_push_image "someimagewedonthave:latest")
    ! (dockerhub_push_image "cat/someimagewedonthave:latest")
}
