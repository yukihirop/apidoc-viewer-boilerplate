# 参考
# https://qiita.com/rh_taro/items/e2b4a0da4b7975921ff7
FROM ruby:2.5.3-alpine
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache openssh git tzdata libxml2-dev curl-dev make gcc libc-dev g++ nodejs yarn postgresql-dev

RUN gem install bundler

ENV APP_HOME /app
WORKDIR $APP_HOME

ENV RAILS_ENV='production'
ENV RACK_ENV='production'
# https://github.com/rails/webpacker/issues/1190#issuecomment-358905190
ENV RAILS_SERVE_STATIC_FILES='true'

ADD Gemfile $APP_HOME
ADD Gemfile.lock $APP_HOME
ADD package.json $APP_HOME
ADD yarn.lock $APP_HOME

# MEMO: If you access private repository
#
# RUN mkdir -p /root/.ssh
# COPY ./tmp/certs /root/.ssh
# RUN ssh -o StrictHostKeyChecking=no -T git@github.com || true

RUN rm -rf /usr/local/bundle/cache
RUN bundle install --jobs 20 --retry 5 --without development test
RUN yarn install

ADD . $APP_HOME
RUN bundle exec rake assets:precompile
