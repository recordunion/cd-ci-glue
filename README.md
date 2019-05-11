cd-ci-glue
=========

[![Build Status](https://travis-ci.org/madworx/cd-ci-glue.svg?branch=master)](https://travis-ci.org/madworx/cd-ci-glue)

[![Build history](https://buildstats.info/travisci/chart/madworx/cd-ci-glue?branch=master)](https://travis-ci.org/madworx/cd-ci-glue/builds)

A small collection of helper  functions for interacting with GitHub,
Docker Hub, and Travis CI.

Primarily designed to  be sourced in Travis CI  scripts to automate
publishing of artifacts and documentation.

## Usage example

``` shell
$ source <(curl 'https://raw.githubusercontent.com/madworx/cd-ci-glue/master/src/cd-ci-glue.bash')

$ make docker && \
  is_travis_master_push && \
  dockerhub_push_image madworx/demoimage && \
  dockerhub_set_description madworx/demoimage README.md

$ make wikidocs && \
  is_travis_master_push && \
  GITDOC=$(github_wiki_prepare madworx/demoimage) && \
  cp build/wiki/*.md "${GITDOC}/"
  github_doc_commit "${GITDOC}"
```

## Documentation

Always-up-to-date generated documentation is available here: [cd-ci-glue.bash](https://madworx.github.io/cd-ci-glue/cd-ci-glue_8bash.html).

Code-coverage of test cases is available here: [coverage/](https://madworx.github.io/cd-ci-glue/coverage/).

## Versioning

The `master` branch is always in working state and represents the current state of the library and will always remain backwards-compatible.

Any possible future non-backwards compatible enhancements to the library will be done in a separate branch.

## Contributing

Any and all contributions are welcome, in the form of [pull requests](https://github.com/madworx/cd-ci-glue/pulls).

## License

This project is licensed under the unlicense - see the [LICENSE](LICENSE) file for details.

## Authors

* **Martin Kjellstrand** - *Initial work* - [madworx](https://github.com/madworx)

