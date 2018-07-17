all:	test

test:
	shellcheck -s ksh src/*.bash

.PHONY: test
