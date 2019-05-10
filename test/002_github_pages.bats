#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

@test "Github doc prepare without argument should fail" {
    run _github_doc_prepare
    [ "$status" -eq 1 ]
    (
        unset GH_TOKEN
        run _github_doc_prepare 
        [ "$status" -eq 1 ]
    )
}

@test "Github incorrect github_doc_commit should fail" {
    # No arg
    run github_doc_commit
    [ "$status" -eq 1 ]

    # Non-existent directory
    run github_doc_commit /nonexistant
    [ "$status" -eq 1 ]

    # Incorrect directory
    run github_doc_commit /tmp
    [ "$status" -eq 1 ]
}

@test "Github pages documentation should work" {
    #
    # cd-ci-glue invocation; github_pages_prepare
    #
    GIT_CODIR="$(github_pages_prepare madworx/cd-ci-glue)"

    GIT_REMOTEDIR="$(mktemp -d)"
    ( cd "${GIT_REMOTEDIR}" && git init > /dev/null )

    pushd "${GIT_CODIR}"
    git remote set-url origin "${GIT_REMOTEDIR}"
    git remote set-url origin --push "${GIT_REMOTEDIR}"

    # Generate a random file into the gh-pages repo:
    mkdir -p foo/bar/baz
    dd if=/dev/urandom bs=1k count=1 status=none | sha1sum > foo/bar/baz/random
    popd

    #
    # cd-ci-glue invocation; github_doc_commit
    #
    github_doc_commit "${GIT_CODIR}"
    
    GIT_NEWCLONE="$(mktemp -d)"
    git clone --branch gh-pages "${GIT_REMOTEDIR}" "${GIT_NEWCLONE}"

    #
    # Compare our local clone against what's @ origin:
    #
    diff -uNr -x .git "${GIT_CODIR}" "${GIT_NEWCLONE}"
    rm -rf "${GIT_CODIR}" "${GIT_NEWCLONE}" "${GIT_REMOTEDIR}" || true
}

@test "Github prepare should set user details" {
    GIT_CODIR="$(_github_doc_prepare "madworx/cd-ci-glue" "gh-pages")"
    ( cd "${GIT_CODIR}" && git config --local -l | egrep '^user[.](email|name)' | wc -l | xargs test 2 == )

    GIT_CODIR="$(_github_doc_prepare "madworx/cd-ci-glue")"
    ( cd "${GIT_CODIR}" && git config --local -l | egrep '^user[.](email|name)' | wc -l | xargs test 2 == )
}
