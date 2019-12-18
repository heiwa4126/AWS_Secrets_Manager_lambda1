#!/bin/sh
# see: https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/manage_create-basic-secret.html

. ./secret.conf
SECRET_JSON=`printf '{"username": "%s","password": "%s"}' $USERNAME $PASSWORD`

aws secretsmanager create-secret \
    --name tutorial/MyAwesomeAppSecret \
    --secret-string "$SECRET_JSON" \
    --description "Just for tutorials"
