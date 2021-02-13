#!/bin/bash

dpkg -r --force-depends ruby-thor && \
  gem install thor
