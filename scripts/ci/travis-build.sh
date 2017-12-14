#!/bin/bash

# This script enable PG 9.6, creates the sequel_tools_test_pw database, which can be only
# accessed using a password through localhost, and the sequel_tools_test database which can be
# accessed using the trust method. It also creates the sequel_tools_user user with password
# 'secret'. This way we can test accessing the database both using a username and password or
# other methods defined by pg_hba.conf, such as trust, which doesn't require a password.

sudo /etc/init.d/postgresql stop
PGVERSION=9.6
PGHBA=/etc/postgresql/$PGVERSION/main/pg_hba.conf
sudo bash -c "sed -i '1i host sequel_tools_test_pw all 127.0.0.1/32 md5' $PGHBA"
sudo /etc/init.d/postgresql start $PGVERSION
psql -c "create user sequel_tools_user superuser password 'secret'" postgres
psql -U sequel_tools_user -c "create database sequel_tools_test" postgres
psql -U sequel_tools_user -c "create database sequel_tools_test_pw" postgres
