#!/bin/bash

source ./.env

cp -r ./certs viewer/tmp
cp -r ./certs generator/tmp
cp ./certs/master.key viewer/config/master.key

# build nginx.conf
source 'build_nginx_ssl_prod.sh'

docker-compose -f docker-compose.ssl.yml down
docker volume rm apidoc-viewer_build_repository
docker-compose -f docker-compose.ssl.yml build --no-cache server
CURRENT_DATE=$(date) docker-compose -f docker-compose.ssl.yml build $1 generator viewer_backend viewer_frontend viewer_db
docker-compose -f docker-compose.ssl.yml run viewer_backend rails db:create db:migrate RAILS_ENV=production
docker-compose -f docker-compose.ssl.yml up
