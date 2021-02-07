#!/bin/bash

cd `dirname $0`

/etc/init.d/mysql start

mysqladmin create ottwatch

../app/bin/rails db:migrate