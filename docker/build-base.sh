#!/bin/bash

cd `dirname $0`

docker build -t ottwatch-base - < Dockerfile.base
