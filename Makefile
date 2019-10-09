all:	test coverage docs

lint:
	shellcheck -s ksh src/*.bash

test: lint
	bats test/*.bats

coverage:
	bashcov --root ./src -- $$(which bats) ./test/*.bats

docs:
	rm -rf docs 2>/dev/null || true
	mkdir docs
	[ -f doxygen-bash.sed ] || \
		curl -O 'https://raw.githubusercontent.com/Anvil/bash-doxygen/94094df8620d8da7e90d5477034b0356d3ef05e3/doxygen-bash.sed'
	doxygen Doxyfile

#
# Generate documentation, run linting and coverage tests using dind-container.
#
docker-all:
	docker build -t test .
	docker kill dind || true
	docker run --rm --name dind --privileged -v $$(pwd):/app -d test
	docker exec -w /app dind /bin/sh -c "\
		while [ ! -S /var/run/docker.sock ] ; do \
			sleep 0.5 ; \
			echo -n . ; \
		done ; \
		chmod 777 /var/run/docker.sock ; \
		adduser -u $$(id -u) coverage < /dev/null || true"
	docker exec \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_DEFAULT_REGION \
		-e AWS_SECRET_ACCESS_KEY \
		-e DOCKER_PASSWORD \
		-e DOCKER_USERNAME \
		-e GH_TOKEN \
		-w /app --user=$$(id -u) \
	  dind make lint docs coverage

.PHONY: test docs lint coverage docker-all
