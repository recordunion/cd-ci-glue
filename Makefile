all:	test

test:
	shellcheck -s ksh src/*.bash
	bats test/*.bats

.PHONY: test
