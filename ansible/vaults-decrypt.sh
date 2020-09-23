#!/usr/bin/env bash

#for FILE in $(ls group_vars/vault* group_vars/*.vault 2>/dev/null)
#do
#    ansible-vault decrypt $FILE
#done

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

ACTION=decrypt

for VAULT in vaults/*
do
  echo "${BOLD}*** Found ${YELLOW}${VAULT}${NORMAL}"

  VAULT=$(basename $VAULT)

  if [ -f "${VAULT}.pass" ]
  then
    echo "${GREEN}   Passfile found, proceeding...${NORMAL}"
    ln -sf ${VAULT}.pass vault.pass
    ansible-vault ${ACTION} vaults/${VAULT} 2>/dev/null
  else
    echo "${RED}   Passfile not found, skipping...${NORMAL}"
  fi
done
