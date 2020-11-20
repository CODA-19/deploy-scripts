#!/bin/sh

STRING=$(cat /cookie.txt)

while true; do
  DATE=$(date -Iseconds)
  echo "${DATE} ${STRING}"
  sleep 5
done
