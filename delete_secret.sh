#!/bin/sh
# see: https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/manage_create-basic-secret.html
. ./secret.conf
aws secretsmanager delete-secret \
    --secret-id "$SECRET_ID" \
    --force-delete-without-recovery
