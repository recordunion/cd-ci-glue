#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

@test "Github Wiki should work" {
    WIKIDIR=$(github_wiki_prepare "madworx/playground")
    
    INDICATOR_FILE="bats-$(date +%s)"
    
    # Directory should initially have been cleared out.
    find "${WIKIDIR}" -mindepth 1 -not -path '*/.git*' -exec false {} +

    # Let's add our indicator file:
    echo "This is BATS automated testing for cd-ci-glue." > "${WIKIDIR}/${INDICATOR_FILE}"

    # Commit it.
    github_wiki_commit "${WIKIDIR}"

    # Check it out again, should now be available if we reset it.
    WIKIDIR=$(github_wiki_prepare "madworx/playground")

    cd "${WIKIDIR}"
    git reset --hard
    [ -f "${INDICATOR_FILE}" ]
    git rm "${INDICATOR_FILE}"

    # Ensure that we don't leave the repo completely empty.
    # Older versions of the git tool may fail attempting to check
    # out an empty repo.
    touch "${WIKIDIR}/non-empty"
    
    github_wiki_commit "${WIKIDIR}"
}
