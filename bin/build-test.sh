#!/bin/bash

touch Dockerfile.test

rm /tmp/test.log

docker build -t ottwatch-test -f Dockerfile.test . && \
  docker container rm ottwatch-test && \
  docker run -t --name ottwatch-test ottwatch-test

docker cp ottwatch-test:/tmp/test.log /tmp/test.log

cat /tmp/test.log
