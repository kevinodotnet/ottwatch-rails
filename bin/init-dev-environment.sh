#!/bin/bash

cd `dirname $0`
cd ../app

/etc/init.d/mysql start

bundle install

bin/rails db:create
bin/rails db:migrate
bin/rails db:migrate RAILS_ENV=test
