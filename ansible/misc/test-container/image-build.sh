#!/usr/bin/env bash

echo
echo "**** BUILD ****"
echo

echo $( openssl rand -base64 12 ) > cookie.txt
docker build -t local/test .
