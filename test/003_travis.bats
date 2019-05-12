#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue
load bats-common

@test "Travis CI operations should match" {
    (TRAVIS_BRANCH=master TRAVIS_EVENT_TYPE=push is_travis_master_push)
    (TRAVIS_BRANCH=foobranch TRAVIS_EVENT_TYPE=push is_travis_branch_push foobranch)
}

@test "Travis CI operations should be false" {
    ! (TRAVIS_BRANCH=notmaster TRAVIS_EVENT_TYPE=push is_travis_master_push)
    ! (TRAVIS_BRANCH=notfoo TRAVIS_EVENT_TYPE=push is_travis_branch_push foobranch)
}

@test "Travis CI outside of travis should fail" {
    TRAVIS_BRANCH=master
    TRAVIS_EVENT_TYPE=push
    
    (
        unset TRAVIS_EVENT_TYPE
        ! (is_travis_master_push)
        ! (is_travis_branch_push master)
    )
    (
        unset TRAVIS_BRANCH
        ! (is_travis_master_push)
        ! (is_travis_branch_push master)
    )
    (
        unset TRAVIS_BRANCH
        unset TRAVIS_EVENT_TYPE
        ! (is_travis_master_push)
        ! (is_travis_branch_push master)
    )

}
