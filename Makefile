all:	test

test:
	shellcheck -s ksh src/*.bash
	bats test/*.bats

docs:
	rm -rf docs 2>/dev/null || true
	mkdir docs
	[ -f doxygen-bash.sed ] || \
		curl -O 'https://raw.githubusercontent.com/Anvil/bash-doxygen/94094df8620d8da7e90d5477034b0356d3ef05e3/doxygen-bash.sed'
	doxygen Doxyfile

.PHONY: test docs
