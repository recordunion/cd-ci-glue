#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

@test "Github get latest release on public repo w/o credentials should work" {
    # "Travis CI has exceeded the number of unauthenticated requests... :-/"
    skip
    (
        unset GH_TOKEN
        LATEST=$(github_releases_get_latest madworx/robotframework-kicadlibrary) || false
        [ "${LATEST}" != "" ]
    )
}

@test "Github get latest release on private repo w/o credentials should fail" {
    (
        unset GH_TOKEN
        ! LATEST=$(github_releases_get_latest madworx/playground)
        [ "${LATEST}" == "" ]
    )
}

@test "Github get latest release on non-existing repo should fail" {
    ! LATEST=$(github_releases_get_latest darmok/jalad)
    [ "${LATEST}" == "" ]
}

@test "Github get latest release on private repo with credentials should work" {
    LATEST=$(github_releases_get_latest madworx/playground) || false
    [ "${LATEST}" != "" ]
}
