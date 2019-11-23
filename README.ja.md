## API Document Viewer Boilerplate

認証付きのAPIドキュメントのビューワーのボイラープレートです。

このボイラープレートの例では、google-oauth2認証(divise無し)でmoneyforwardのAPIドキュメントをslate形式に変換して表示しております。

moneyforwardのAPIドキュメントに関しては本家からお借りしております。

[本家はこちら](https://github.com/moneyforward/expense-api-doc)

## Product

#### before authorize

![before authorize](https://user-images.githubusercontent.com/11146767/68112436-a6015c00-ff34-11e9-86c1-7047537c0dd9.png)

#### after authorize

![after authorize](https://user-images.githubusercontent.com/11146767/68111211-f2976800-ff31-11e9-937e-e6a7845950c6.png)

## Dependencies

- yarn (1.19.0)
- nodejs (v12.7.0)
- webpack (4.41.2)
- ruby (ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin18])
- Rails (6.0.0)
- slate (latest)
- widdershins (latest)
- js-yaml (latest)

## Components

このツールのコンポーネント群に関しての説明です。

|コンポーネント|説明|
|-------------|----|
|apidoc|`generator` で生成された成果物(APIドキュメント)を動かすためのサーバー。IPアドレス制限をしており、`viewer` からしかAPIドキュメントを参照できないように設定されている。|
|certs|githubにアクセスするための公開鍵と秘密鍵を `id_rsa` と `id_rsa.pub` という名前で用意します。|
|generator|表示したいAPIドキュメントの成果物を用意します。`build` ディレクトリに `index.html` が含まれる形になるようにしてください。この例では、moneyforwardのAPIドキュメント(OpenAPI)を `widdershins` というツールでslate形式のマークダウンに変換して、slateでビルドして用意しております。|
|viewer|google-oauth2認証付きのAPIドキュメントビューワー。認証をパスするとiframeで `apidoc` で動いているAPIドキュメントを表示する仕組みになっている。|
|tmp|ビルド時の一時成果物が吐き出される場所。現在は、ERB形式のnginxの設定ファイルのビルド結果を吐き出す場所になっている。|

## Environments

|項目|詳細|初期値|
|---|----|-----|
|APIDOC_TITLE|APIドキュメントのタイトル|`moneyforward`|
|APIDOC_URL|`apidoc`のサーバーURL|`http://0.0.0.0:8080`|
|VIEWER_DATABASE_NAME|`viewer`のデータベース名|`viewer_production`|
|VIEWER_DATABASE_USERNAME|`viewer`のデータベースのユーザー名|`postgres`|
|VIEWER_DATABASE_PASSWORD|`viewer`のデータベースのパスワード||
|VIEWER_DATABASE_PORT|`viewer`のデータベースのポート|`5432`|
|GOOGLE_CLIENT_ID|google-oauth2のクライアントID||
|GOOGLE_CLIENT_SECRET|google-oauth2のクライアントシークレット||
|VIEWER_PORT|`viewer`のポート|`3000`|
|APIDOC_PORT|`apidoc`のポート|`8080`|
|APIDOC_SERVER_NAME|`apidoc`のサーバーネーム|`_`|
|APIDOC_SSL_PORT|`apidoc`のsslポート|`443`|
|APIDOC_SSL_CERT|`apidoc`の証明書ファイル||
|APIDOC_SSL_CERT_KEY|`apidoc`の秘密鍵||
|APP_BRANCH|APIドキュメントのファイルを管理しているアプリのブランチ|`master`|
|IPV4_ADDRESS_APIDOC|`apidoc`のIPアドレス|`172.25.0.103`|
|IPV4_ADDRESS_VIEWER_BACKEND|`viewer(backend)`のIPアドレス|`172.25.0.100`|
|IPV4_ADDRESS_VIEWER_FRONTEND|`viewer(frontend)`のIPアドレス|`172.25.0.101`|
|IPV4_ADDRESS_VIEWER_DB|`viewer(db)`のIPアドレス|`172.25.0.102`|
|IPV4_ADDRESS_GENERATOR|`generator`のIPアドレス|`172.25.0.104`|
|APIDOC_SUBNET|APIドキュメントを表示するためのコンポーネント郡のサブネット|`172.25.0.0/24`|
|APIDOC_SUBNET_DEFAULT_GATEWAY|サブネットのデフォルトゲートウェイ|`172.25.0.1`|
|EXTERNAL_IP|デプロイ先のインスタンスの外部IP|`127.0.0.1`|
|ELB_SUBNET_ADDRESS|ELBのネットワークアドレス||
|HSTS_MAX_AGE|HTTP_Strict_Transport_Securityのmax_age(本番SSLでのみ有効)|`31536000`|

## Deploy

`.env`  ファイルを用意する。コピーしてから適切に設定する。

`GOOGLE_CLIENT_ID` ・ `GOOGLE_CLIENT_SECRET` を設定すれば動くはずである。

```bash
cp .env.sample .env
```

privateリポジトリにアクセスする場合は、秘密鍵と公開鍵をコピーする。名前は必ず `id_rsa`・`id_rsa.pub` とする。

```bash
cp ~/.ssh/id_rsa ./certs/id_rsa
cp ~/.ssh/id_rsa.pub ./certs/id_rsa.pub
```

viewrをproduction環境で使うための設定が必要で以下のコマンドを実行して、`config/master.key` を用意する。

```bash
cd viewer
bundle install --path vendor/bundle
rm config/master.key
rm config/credentials.yml.enc
EDITOR=vim bundle exec rails credentials:edit
```

Dockerイメージキャッシュを使ってデプロイする場合

```bash
/bin/bash deploy_dev.sh # 開発
/bin/bash deploy_prod.sh # 本番
```

Dokcerイメージキャッシュを使わないでデプロイする場合

```bash
/bin/bash deploy_dev.sh --no-cache # 開発
/bin/bash deploy_prod.sh --no-cache # 本番
```

※ --no-cache を指定してないのに設定が悪いのかキャッシュしてほしいイメージのキャッシュが効かない不具合がありますが動作には影響しません。

※ 時間が結構かかり、5〜10分くらいかかります。


## Deploy (ssl)

こちらのドキュメントを参考にして、 `apidoc/ssl` に `証明書ファイル` と `秘密鍵` を用意します。

あとは `Deploy` の方とやり方は同じです。

Dockerイメージキャッシュを使ってデプロイする場合

```bash
/bin/bash deploy_ssl_dev.sh # 開発
/bin/bash deploy_ssl_prod.sh # 本番
```

Dokcerイメージキャッシュを使わないでデプロイする場合

```bash
/bin/bash deploy_ssl_dev.sh --no-cache # 開発
/bin/bash deploy_ssl_prod.sh --no-cache # 本番
```
