#!/bin/bash

cd `dirname $0`
cd ..

docker run \
  -v `pwd`:/app \
  -i -t \
  --name ottwatch-dev \
  ottwatch-dev

