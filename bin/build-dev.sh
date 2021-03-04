#!/bin/bash

cd `dirname $0`
cd ..

docker build -t ottwatch-dev -f Dockerfile.dev .

