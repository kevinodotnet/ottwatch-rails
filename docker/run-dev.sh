#!/bin/bash

cd `dirname $0`
cd ..

docker container rm ottwatch-dev 2>/dev/null

docker run \
  -v `pwd`:/ottwatch \
  -p 33000:3000 \
  -i -t \
  --name ottwatch-dev \
  ottwatch-dev

