#!/usr/bin/env bash

mkdir -p keypairs
rm -rf keypairs/*

SITES=(100 101 102 103 104 105 106 107 108)

for SITE in ${SITES[@]}; do
  ssh-keygen -b 4096 -f keypairs/id_rsa-${SITE} -N ''
done
