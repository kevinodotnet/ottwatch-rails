#!/bin/bash

cd `dirname $0`
cd ..

docker build -t ottwatch-base -f Dockerfile.base .

