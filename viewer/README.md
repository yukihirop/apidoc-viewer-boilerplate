# Viewer

## development

```bash
$ cp .envrc.sample .envrc
```

and set value.

#### frontend

```
$ yarn
$ bin/webpack-dev-server
```

#### backend

```
$ bundle install --path vendor/bundle
$ bundle exec rails db:create db:migrate
$ bundle exec rails s
```
