#!/usr/bin/env bats
# -*- mode: sh -*-

load ../src/cd-ci-glue

@test "dockerhub operations without variables should fail" {
  run dockerhub_push_image
  [ "$status" -eq 1 ]
  run dockerhub_set_description madworx/foobar $0
  [ "$status" -eq 1 ]
  run dockerhub_set_description madworx/foobar
  [ "$status" -eq 1 ]
  run dockerhub_set_description
  [ "$status" -eq 1 ]
}
