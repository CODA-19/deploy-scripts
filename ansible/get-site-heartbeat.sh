#!/usr/bin/env bash

#### PARAMETERS

CODA19_SITE_ID=$1
CODA19_HOST_ROLE=$2

CODA19_HEARTBEAT_BASE_URL=https://heartbeat.hub.coda19.com
CODA19_HEARTBEAT_TOKEN=$( cat heartbeat-token.100 )
CODA19_HEARTBEAT_CONNECT_TIMEOUT=5

#### DEFINE COLORS AND FUNCTIONS

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

function header {
    echo "${NORMAL}"
    echo "${BOLD}${YELLOW}**********************************************************************${NORMAL}"
    echo "${BOLD}${YELLOW}***${NORMAL}${YELLOW} $1 ${NORMAL}"
    echo "${BOLD}${YELLOW}**********************************************************************${NORMAL}"
    echo "${NORMAL}"
}

#### SHOW VARIOUS HEARTBEAT STATUSES

header "ANSIBLE LOG TAIL"

curl \
  --cipher 'DEFAULT:!DH' \
  --silent \
  --connect-timeout ${CODA19_HEARTBEAT_CONNECT_TIMEOUT} \
  --request GET \
  --header "Authorization: ${CODA19_HEARTBEAT_TOKEN}" \
  ${CODA19_HEARTBEAT_BASE_URL}/logs/${CODA19_SITE_ID}/${CODA19_HOST_ROLE}/ansible | tail -n 50

header "SYSTEM INFORMATION"

curl \
  --cipher 'DEFAULT:!DH' \
  --silent \
  --connect-timeout ${CODA19_HEARTBEAT_CONNECT_TIMEOUT} \
  --request GET \
  --header "Authorization: ${CODA19_HEARTBEAT_TOKEN}" \
  ${CODA19_HEARTBEAT_BASE_URL}/sysinfo/${CODA19_SITE_ID}/${CODA19_HOST_ROLE}

header "NODE_EXPORTER METRICS TAIL"

curl \
  --cipher 'DEFAULT:!DH' \
  --silent \
  --connect-timeout ${CODA19_HEARTBEAT_CONNECT_TIMEOUT} \
  --request GET \
  --header "Authorization: ${CODA19_HEARTBEAT_TOKEN}" \
  ${CODA19_HEARTBEAT_BASE_URL}/metrics/${CODA19_SITE_ID}/${CODA19_HOST_ROLE} | head -n 5
