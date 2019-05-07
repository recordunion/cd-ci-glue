#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

@test "Travis CI operations should match" {
    TRAVIS_BRANCH=master TRAVIS_EVENT_TYPE=push is_travis_master_push
    TRAVIS_BRANCH=foobranch TRAVIS_EVENT_TYPE=push is_travis_branch_push foobranch
}

@test "Travis CI operations should be false" {
    TRAVIS_BRANCH=notmaster TRAVIS_EVENT_TYPE=push run is_travis_master_push
    [ "$status" -eq 1 ]
    TRAVIS_BRANCH=notfoo TRAVIS_EVENT_TYPE=push run is_travis_branch_push foobranch
    [ "$status" -eq 1 ]
}

@test "Travis CI outside of travis should fail" {
    TRAVIS_BRANCH=master
    TRAVIS_EVENT_TYPE=push
    (
        unset TRAVIS_BRANCH
        unset TRAVIS_EVENT_TYPE
        run is_travis_master_push
        [ "$status" -eq 1 ]
        run is_travis_branch_push master
        [ "$status" -eq 1 ]
    )
    (
        unset TRAVIS_EVENT_TYPE
        run is_travis_master_push
        [ "$status" -eq 1 ]
        run is_travis_branch_push master
        [ "$status" -eq 1 ]
    )
    (
        unset TRAVIS_BRANCH
        run is_travis_master_push
        [ "$status" -eq 1 ]
        run is_travis_branch_push master
        [ "$status" -eq 1 ]
    )

}
