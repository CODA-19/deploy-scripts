#!/usr/bin/env bash

mkdir -p keypairs
rm -rf keypairs/*

for SITE in {110..120}; do
  ssh-keygen -b 4096 -f keypairs/id_rsa.${SITE} -N '' -C "site${SITE}@coda19.com"
done
