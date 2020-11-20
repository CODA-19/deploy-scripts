#!/usr/bin/env bash

echo
echo "**** PUSH ****"
echo

docker login docker.io

docker tag  local/test \
            docker.io/coda19/test

docker push docker.io/coda19/test
