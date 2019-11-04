#!/bin/bash

source ./.env

cp -r ./certs viewer/tmp
cp -r ./certs generator/tmp

# build nginx.conf
if [ ! -d tmp ]; then
  mkdir tmp
fi
APIDOC_SERVER_NAME=${APIDOC_SERVER_NAME} APIDOC_SUBNET_DEFAULT_GATEWAY=${APIDOC_SUBNET_DEFAULT_GATEWAY} IPV4_ADDRESS_VIEWER_BACKEND=${IPV4_ADDRESS_VIEWER_BACKEND} /usr/bin/erb ./apidoc/nginx.conf.erb > ./tmp/nginx.conf

docker-compose down
CURRENT_DATE=$(date) docker-compose build $1
docker-compose run viewer_backend rake db:create db:migrate RAILS_ENV=production
docker-compose up
