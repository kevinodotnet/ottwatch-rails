#!/bin/bash

cd `dirname $0`

/etc/init.d/mysql start

mysqladmin create ottwatch_dev
mysqladmin create ottwatch_test

../app/bin/rails db:migrate
