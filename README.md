# AWS Secrets Manager メモ part 2/2

Twitter APIのキー4つをlambdaに埋め込まない、
という件で調査したときのサンプルコード第2部

# 作業

(続き)

読める権限はどこで設定するのか。

- [Secrets Manager でアイデンティティベースのポリシー (IAM ポリシー) を使用する - AWS Secrets Manager](https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/auth-and-access_identity-based-policies.html)
- [消費側アプリケーションの場合 : 1 つのシークレットキーへの読み込みアクセスの付与](https://docs.aws.amazon.com/ja_jp/secretsmanager/latest/userguide/auth-and-access_identity-based-policies.html#permissions_grant-get-secret-value-to-one-secret)

かんたんなlambdaを書いてみる。

SAMでちょいちょいと作ったlambda。
ローカルで動かすとsecretが見える。

発行してみるとエラーになる(それでOK)。

template.yamlに
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
これをyamlにしたやつを追加。

sam build & sam deploy & curl でちゃんと動くことを確認

これあんまりよくなくて、
template.yamlでsecretのリソースも作って、
後からsecretを設定するべきなんだろうか。

それではローカルテストができない。

開発&テストぬきでデプロイはできる。

キー(に限らず)の共用ができない。

せめてARNを直書きしない方法があれば。
