# MEMO:
# https://gist.github.com/iagopiimenta/d522fb2aa53b90597924488c070597ac
FROM ruby:3.3.0-alpine as base
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache sudo openssh git tzdata libxml2-dev curl-dev make gcc libc-dev g++ build-base mariadb-dev nodejs nodejs-npm

ENV APP_HOME /app
WORKDIR $APP_HOME

RUN mkdir -p /root/.ssh
COPY ./tmp/certs /root/.ssh
RUN ssh -o StrictHostKeyChecking=no -T git@github.com || true

COPY /bin $APP_HOME/bin
COPY /config $APP_HOME/config
RUN $APP_HOME/bin/setup-common

# app
FROM base as app
ARG current_date
ENV BUNDLER_DEFAULT_PATH /usr/local/lib/ruby/gems/2.5.0
ENV BUNDLER_VERSION 2.0.2

RUN sudo gem uninstall bundler -xi $BUNDLER_DEFAULT_PATH --all && \
    gem install bundler --version $BUNDLER_VERSION

# cache
RUN $APP_HOME/bin/setup-app-initial
# no cache
RUN echo $current_date > /dev/null && $APP_HOME/bin/setup-app-each

# slate
FROM base as slate
ARG current_date
ENV BUNDLER_DEFAULT_PATH /usr/local/lib/ruby/gems/2.5.0
ENV BUNDLER_VERSION 2.0.2

RUN sudo gem uninstall bundler -xi $BUNDLER_DEFAULT_PATH --all && \
    gem install bundler --version $BUNDLER_VERSION && \
    npm install --g widdershins js-yaml

COPY --from=app /tmp/apidoc.yaml /tmp/apidoc.yaml
# cache
RUN $APP_HOME/bin/setup-slate-initial
# no cache
RUN echo $current_date > /dev/null && $APP_HOME/bin/setup-slate-each
