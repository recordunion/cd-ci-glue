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
    run github_doc_commit
    [ "$status" -eq 1 ]
    run github_doc_commit /nonexistant
    [ "$status" -eq 1 ]
    run github_doc_commit /tmp
    [ "$status" -eq 1 ]
}

@test "Github pages documentation should work" {
    #
    # cd-ci-glue invocation; github_pages_prepare
    #
    run github_pages_prepare madworx/cd-ci-glue
    GIT_CODIR="${lines[@]}"
    [ "$status" -eq 0 ]
    
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
    run github_doc_commit "${GIT_CODIR}"
    [ "$status" -eq 0 ]
    
    GIT_NEWCLONE="$(mktemp -d)"
    git clone --branch gh-pages "${GIT_REMOTEDIR}" "${GIT_NEWCLONE}"

    #
    # Compare our local clone against what's @ origin:
    #
    diff -uNr -x .git "${GIT_CODIR}" "${GIT_NEWCLONE}"
    rm -rf "${GIT_CODIR}" "${GIT_NEWCLONE}" "${GIT_REMOTEDIR}" || true
}

@test "Github prepare should set user details" {
    run _github_doc_prepare "madworx/cd-ci-glue" "gh-pages"
    GIT_CODIR="${lines[@]}"
    [ "$status" -eq 0 ]
    ( cd "${GIT_CODIR}" && git config --local -l | egrep '^user[.](email|name)' | wc -l | xargs test 2 == )

    run _github_doc_prepare "madworx/cd-ci-glue"
    GIT_CODIR="${lines[@]}"
    [ "$status" -eq 0 ]
    ( cd "${GIT_CODIR}" && git config --local -l | egrep '^user[.](email|name)' | wc -l | xargs test 2 == )
}
