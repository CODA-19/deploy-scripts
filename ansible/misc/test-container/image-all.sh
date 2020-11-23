#!/usr/bin/env bash

./image-build.sh
./image-push.sh

echo
echo "**** CURRENT COOKIE ****"
echo

cat cookie.txt
