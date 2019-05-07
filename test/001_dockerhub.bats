#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

DOCKER_IMAGE=madworx/cdci-dummy-test

@test "DockerHub down should fail" {
    _DOCKERHUB_URL="http://localhost"
    run dockerhub_set_description "${DOCKER_IMAGE}" <(echo "Last tested: $(date)")
    [ "$status" -eq 1 ]
}

@test "DockerHub description update w/ incorrect credentials should fail" {
    (
        DOCKER_PASSWORD=incorrectpassword
        run dockerhub_set_description "${DOCKER_IMAGE}" <(echo "Last tested: $(date)")
        [ "$status" -eq 1 ]
    )
}

@test "DockerHub operations without credentials should fail" {
    (
        unset DOCKER_USERNAME
        unset DOCKER_PASSWORD

        run dockerhub_push_image
        [ "$status" -eq 1 ]
        run dockerhub_set_description "${DOCKER_IMAGE}" $0
        [ "$status" -eq 1 ]
        run dockerhub_set_description "${DOCKER_IMAGE}"
        [ "$status" -eq 1 ]
        run dockerhub_set_description
        [ "$status" -eq 1 ]
        run dockerhub_push_image "${DOCKER_IMAGE}:latest"
        [ "$status" -eq 1 ]
    )
}

@test "DockerHub description update should work" {
    dockerhub_set_description "${DOCKER_IMAGE}" <(echo "Last tested: $(date)")

}

@test "DockerHub image push should work" {
    docker build -t "${DOCKER_IMAGE}:latest" -f - . < <(echo -e 'FROM scratch\nMAINTAINER "dummy"')
    dockerhub_push_image "${DOCKER_IMAGE}:latest"
}

