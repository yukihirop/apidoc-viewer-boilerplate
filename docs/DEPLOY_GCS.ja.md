# 1から環境を整えGCPにデプロイするやり方

## インスタンス作成

以下のコマンドでインスタンスを作成する。この例だとインスタンス名は `apidoc-viewer-boilerplate` となっている。

ディスク容量は20GBにしている。ディスク容量はいつでも変更可能である。

イメージは、ubuntu-1910-eoan-v20191022 である。

必要な環境変数は `PROJECT_ID` と `SERVICE_ACCOUNT` である。

```BASH
gcloud beta compute --project=${PROJECT_ID} instances create apidoc-viewer-boilerplate \
 --zone=asia-northeast1-a \
 --machine-type=n1-standard-1 \
 --subnet=default \
 --network-tier=PREMIUM \
 --maintenance-policy=MIGRATE \
 --service-account=${SERVICE_ACCOUNT} \
 --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
 --tags=http-server,https-server, apidoc-viewer-boilerplate \
 --image=ubuntu-1910-eoan-v20191022 \
 --image-project=ubuntu-os-cloud \
 --boot-disk-size=20GB \
 --boot-disk-type=pd-standard \
 --boot-disk-device-name=test-apidoc-viewer-boilerplate \
 --reservation-affinity=any
```

以下のコマンドでssh接続できる事を確認する。

```
gcloud beta compute --project ${PROJECT_ID} ssh --zone "asia-northeast1-a" "apidoc-viewer-boilerplate"
```

## ファイヤーウォールの設定

`APIDOC_PORT` および `APIDOC_SSL_PORT` に設定したポートでファイヤーウォールの設定を行う。

社内で使う場合はソースレンジ(`SOURCE_RANGE`)を指定したが安全である。

```BASH
gcloud compute --project=zenlogic-data-warehouse-sbx firewall-rules create NAME
 --direction=INGRESS
 --priority=1000
 --network=default
 --action=ALLOW
 --source-ranges=${SOURCE_RANGE}
 --rules=tcp:${APIDOC_PORT},${APIDOC_SSL_PORT}
 --target-tags=apidoc-viewer-boilerplate
```

## 公開鍵と秘密鍵を登録

公開したいドキュメントがprivateリポジトリの場合は公開鍵と秘密鍵をインスタンスにコピーしないとインスタンスからgit cloneできない。

scpコマンドを使用して公開鍵と秘密鍵をコピーする。

```bash
gcloud beta compute --project ${PROJECT_ID} scp ~/.ssh/id_rsa --zone "asia-northeast1-a" "apidoc-viewer-boilerplate":~/.ssh
gcloud beta compute --project ${PROJECT_ID} scp ~/.ssh/id_rsa.pub --zone "asia-northeast1-a" "apidoc-viewer-boilerplate":~/.ssh
```

## erbを使えるようにする

nginxのconfファイルはERB形式のテンプレートになっているのでerbコマンドを使えるようにする必要がある。

erbはrubyのビルトインコマンドなのでrubyをインストールする。

rubyはrbenvとruby-buildで好きなバージョンを入れれるようにしている。

#### rbenvのインストール

rbenvをビルドしたり、rubyをインストールしたりするための依存パッケージをインストールする必要がある。

```bash
sudo apt-get -y install gcc make libssl-dev libreadline-dev zlib1g-dev
```

続いてrbenvのインストール

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
```

#### ruby-buildのインストール

複数のバージョンのrubyをインストールできるようにするためにはruby-buildが必要であるのでインストールする。

```bash
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

#### rubyのインストール

```bash
rbenv install 2.5.3
rbenv global 2.5.3
rbenv rehash
```

確認する。

```bash
which ruby
which erb
```

## dockerを使えるようにする

#### 依存パッケージのインストール

```bash
sudo apt get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
```

#### GPG公開鍵のインストール

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

公開鍵のフィンガープリントを確認する。

```bash
sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

#### aptリポジトリの設定

archコマンドでアーキテクチャーを確認する

```bash
arch
x86_64
```

```bash
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
```

`eoan` がなかったので代わりに `disco` を使用した。 [issue](https://github.com/docker/for-linux/issues/833#issuecomment-544257796)

```bash
sudo add-apt-repository
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  disco \
  stable"
```

#### docker-ceのインストール

```bash
sudo apt-get update
sudo apt-get install -y docker-ce
```

確認する。

```bash
Client: Docker Engine - Community
 Version:           19.03.3
 API version:       1.40
 Go version:        go1.12.10
 Git commit:        a872fc2f86
 Built:             Tue Oct  8 01:00:44 2019
 OS/Arch:           linux/amd64
 Experimental:      false
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.40/version: dial unix /var/run/docker.sock: connect: permission denied
```

[Ubuntuにdockerをインストールする](https://qiita.com/tkyonezu/items/0f6da57eb2d823d2611d)


#### docker-composeを使えるようにする

dokcer-composeの安定版のインストール

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

実行権限を与える。

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

確認する。

```
which docker-compose
/usr/local/bin/docker-compose
```

## その他あると良さそうなツール

```rbenv
rbenv exec gem install -N bundler
```

## やっておいたが良い設定

ログインユーザーで実行できるように所有者とグループを変更しておく。

デフォルトでは `root:root` になっている。

```bash
sudo chown $(id -un):$(id -un) /usr/bin/docker
sudo chown $(id -un):$(id -un) /usr/local/bin/docker-compose
sudo chown $(id -un):$(id -un) /var/run/docker.sock
```

## デプロイする(gcpのインスタンスにsshした状態で行う)

git cloneの時はいらないがgit pullしてくる時に必要になるので設定しておく。

```bash
git config --global user.email "yoour@example.com"
git config --global user.name "yourname"
```

cloneしてくる。

```bash
git clone git@github.com:yukihirop/apidoc-viewer-boilerplate.git
cd apidoc-viewer-boilerplate
cp ~/.ssh/id_rsa ./certs/id_rsa
cp ~/.ssh/id_rsa.pub ./certs/id_rsa.pub
cp .env.sample .env
```

`.env` を適切に設定する。

```bash
cd viewer
bundle install --path vendor/bundle
```

デプロイする。

```bash
/bin/bash deploy_prod.sh
/bin/bash deploy_prod.sh --no-cache     # Dockerのイメージのキャッシュを使わない
/bin/bash deploy_ssl_prod.sh
/bin/bash deploy_ssl_prod.sh --no-cache # Dockerのイメージのキャッシュを使わない
```
