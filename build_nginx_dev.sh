#!/bin/bash

source ./.env

# build nginx.conf
if [ ! -d tmp ]; then
  mkdir tmp
fi

APIDOC_SERVER_NAME=${APIDOC_SERVER_NAME} \
APIDOC_SUBNET_DEFAULT_GATEWAY=${APIDOC_SUBNET_DEFAULT_GATEWAY} \
IPV4_ADDRESS_VIEWER_BACKEND=${IPV4_ADDRESS_VIEWER_BACKEND} \
EXTERNAL_IP=${EXTERNAL_IP} \
erb ./apidoc/nginx_dev.conf.erb > ./tmp/nginx.conf
