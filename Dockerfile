FROM docker:dind

RUN apk add build-base ruby ruby-dev ruby-rdoc py-pip bats curl doxygen bash git diffutils
RUN apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community shellcheck
RUN pip install awscli
RUN gem install bashcov simplecov etc

ENTRYPOINT [ "dockerd-entrypoint.sh" ]
