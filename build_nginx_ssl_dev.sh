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
APIDOC_SSL_CERT=${APIDOC_SSL_CERT} \
APIDOC_SSL_CERT_KEY=${APIDOC_SSL_CERT_KEY} \
erb ./apidoc/nginx_ssl_dev.conf.erb > ./tmp/nginx.conf
