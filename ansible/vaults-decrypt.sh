#!/usr/bin/env bash

for FILE in $(ls group_vars/vault* group_vars/*.vault 2>/dev/null)
do
    ansible-vault decrypt $FILE
done
