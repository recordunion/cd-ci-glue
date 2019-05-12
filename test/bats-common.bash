# -*- mode: sh -*-

setup() {
    if [ "${BATS_TEST_NUMBER}" == 1 ] ; then
        if declare -f local_suite_setup > /dev/null ; then
            local_suite_setup
        fi
    fi
    if declare -f local_setup > /dev/null ; then
        local_setup
    fi
}

teardown() {
    if [ "${#BATS_TEST_NAMES[@]}" == "$BATS_TEST_NUMBER" ]; then
        if declare -f local_suite_teardown > /dev/null ; then
            local_suite_teardown
        fi
    fi
    if declare -f local_teardown > /dev/null ; then
        local_teardown
    fi
}
