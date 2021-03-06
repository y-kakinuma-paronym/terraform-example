# Terraform Example

## 参考サイト

以下のサイトを参照し構築

[Terraform入門その一（インストール） - Qiita](https://qiita.com/kenkono/items/86fb4544735d9cfad080)

## 作成されるリソース

- AWS
    - EC2
    - ASG (Auto Scaling Group)
    - ELB (Elastic Load Balancing)

## 事前準備

- AWS CLIがインストールされていること
- terraformがインストールされていること
- `aws configure` で `AWS_ACCESS_KEY_ID` と `AWS_SECRET_ACCESS_KEY` が設定されていること

## コマンド

■初期化

```
terraform init
```

■フォーマット整形

```
terraform fmt
```

■設定ファイルのバリエーション

```
terraform validate
```

■デプロイ

```
terraform apply
```

■状態の確認

```
terraform show
```

■作成したリソースの破棄

```
terraform destroy
```
