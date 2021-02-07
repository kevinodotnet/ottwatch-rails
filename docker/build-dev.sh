#!/bin/bash

cd `dirname $0`

./build-base.sh

docker build -t ottwatch-dev - < Dockerfile.dev

