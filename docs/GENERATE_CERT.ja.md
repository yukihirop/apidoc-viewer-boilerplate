# オレオレ証明書の作り方

開発環境では [mkcert](https://github.com/FiloSottile/mkcert) を使用する。

```bash
brew install mkcert
cd apidoc/ssl
mkcert -install
```

生成された

- `0.0.0.0+3.pem` が `証明書ファイル`
- `0.0.0.0+3-key.pem` が `秘密鍵`

となる。
