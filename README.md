# AWS Secrets Manager メモ part 2/2

Twitter APIのキー4つをlambdaに埋め込まない、
という件で調査したときのサンプルコード第2部

[samの生成したREADMEはこちら](/README-org.md)。
デプロイや修正は↑を参照。

いろいろ考えたんだけど
Secrets ManagerはSAM以外で作って、他でも使い回す、
というシナリオで行くことにした。


# デプロイ

## secretを作る

既存のsecretを使いたければ
ポータルなどからARNを得ておく。

もしsecretがなければ

```sh
cp secret.conf.template secret.conf
vim secret.conf
# ↑値を好きなように書き換える
./create_secret.sh
```
Secrets ManagerのARNが表示されるのでメモしておく.


## lambdaをSAMでデプロイする

```sh
sam build
sam deploy --guided
```

`sam deploy`は基本デフォルト値でリターンキーを押すだけでOK。
ただし以下の3つは
- Stack name - APPの名前。sm-test-appなど。使える文字種に制限あり
- AWS Region - 手近なリージョン。ap-northeast-1など
- SecretsManagerARNParameter - さっきメモしたsecretのARN

を入力する。ちゃんとdeployされると

```
SecretTestApi - API Gateway endpoint URL     https://xxxxxxxx.execute-api.ap-
                                             northeast-1.amazonaws.com/Prod/secret/
```
みたいにエンドポイントが表示されるので、ここへcurlかなにかでアクセスする。


`sam deploy --guided`で入力した値は`samconfig.toml`に保存されるので、
2回目以降は

```sh
sam build
sam deploy
```
でOK


アンインストールは
``` sh
aws cloudformation delete-stack --stack-name sm-test-app
```


# 作業

(続き)

読める権限はどこで設定するのか。

- [Secrets Manager でアイデンティティベースのポリシー (IAM ポリシー) を使用する - AWS Secrets Manager](https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/auth-and-access_identity-based-policies.html)
- [消費側アプリケーションの場合 : 1 つのシークレットキーへの読み込みアクセスの付与](https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/auth-and-access_identity-based-policies.html#permissions_grant-get-secret-value-to-one-secret)

かんたんなlambdaを書いてみる。
SAMでちょいちょいと作ったlambda。
ローカルで動かすとsecretが見える。

「ローカルで動かす」の手順
```sh
sam build
sam local start-api &
curl http://127.0.0.1:3000/secret
```

発行してみるとエラーになる(IAMで許可してないのでそれでOK)。

「発行してみると」の手順

最初の1回
```sh
sam build
sam deploy --guided
# "asmlambda1"という名前で
```

2回目以降
```sh
sam build
sam deploy
```

デフォルトのAWSLambdaBasicExecutionRoleを読んでyamlにしたやつと、
さらに
```json
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "<arn-of-the-secret-the-app-needs-to-access>"
    }
}
```
これをyamlにしたやつを
[template.yaml](/template.yaml)に追加。

sam build & sam deploy & curl でちゃんと動くことを確認

これあんまりよくなくて、
template.yamlでsecretのリソースも作って、
後からsecretを設定するべきなんだろうか。

- それではローカルテストができない。
- 開発&テストぬきでデプロイはできる。
- キー(に限らず)の共用ができない。

ちょっとむずかしいね。せめてARNを直書きしない方法があれば(いやそのためにARNがあるのだし)。

# TODO

CloudFormationをもっと勉強しよう。
