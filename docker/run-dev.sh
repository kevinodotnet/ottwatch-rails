#!/bin/bash

cd `dirname $0`
cd ..

docker run \
  -v `pwd`:/app \
  -i -t ottwatch-dev

