#!/bin/bash

cd `dirname $0`

docker build -t ottwatch-dev - < Dockerfile.dev

docker container rm ottwatch-dev
