# abyss0-dev/dns

`abyss0.dev` の DNS レコードを Terraform で管理します。

## スコープ

このリポジトリが管理するのは、`abyss0.dev` zone の DNS レコードと DNSSEC だけです。

- zone そのものは Cloudflare Registrar が所有します。Terraform は `data` で参照するだけで、作成も削除もしません。
- Registrar の設定（自動更新、連絡先）、zone 設定（SSL/TLS など）、Pages、Workers、R2、Access は対象外です。必要になったら、このリポジトリには入れず、別に管理場所を決めてください。
- ダッシュボードで直接レコードを編集しないでください。Terraform の管理外のレコードは plan に表示されません。

## 構成

| パス | 内容 |
| :--- | :--- |
| `terraform/versions.tf` | Terraform、provider、R2 backend の設定 |
| `terraform/zone.tf` | zone の参照と DNSSEC（無効） |
| `terraform/mail.tf` | メールを使わないことの宣言（Null MX、SPF、DMARC） |
| `.github/workflows/plan.yml` | PR と Merge Queue で `terraform plan` |
| `.github/workflows/apply.yml` | `main` への push で `terraform apply` |

## 認証

GitHub Actions は OIDC で 1Password Credential Broker（public preview）に認証し、1Password Environment の変数をすべて環境変数として読み込みます。
plan と apply で Environment を分け、plan 側には読み取り権限だけを与えます。

| 1Password Environment | `CLOUDFLARE_API_TOKEN` | `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`（R2） | 信頼条件 |
| :--- | :--- | :--- | :--- |
| `abyss0-dns-plan` | Zone: DNS Read（`abyss0.dev` のみ） | Object Read only（`abyss0-dns-tfstate` のみ） | repo `abyss0-dev/dns`、environment `abyss0-dns-plan` |
| `abyss0-dns-apply` | Zone: DNS Edit（`abyss0.dev` のみ） | Object Read & Write（`abyss0-dns-tfstate` のみ） | repo `abyss0-dev/dns`、environment `abyss0-dns-apply`、branch `main` |

1Password Environment が読み込まれるのは、上の3変数だけにしてください。Environment 内の変数はすべて job に渡ります。

GitHub の environment には、それぞれ次を設定します。

- variables: `OP_WORKLOAD_ID`、`OP_ENVIRONMENT_ID`
- secrets: `OP_INTEGRATION_KEY`
- `abyss0-dns-apply` だけ、deployment branch を `main` に制限する

fork からの PR には OIDC トークンが渡らないため、plan は失敗します。`pull_request_target` には変更しないでください。

## 初回セットアップ

1. リポジトリを作成し、`./setup-repository.sh` で共通設定を適用する。
2. R2 バケット `abyss0-dns-tfstate` を作成する。state を保持するため、Terraform の外で作成します。
3. 上の表のとおり、Cloudflare API Token と R2 API Token を2組発行し、1Password Environment に登録する。
4. 1Password Environment を GitHub Actions に連携し、GitHub の environment を作成する。
5. 既存レコードを取り込む（次節）。

## 既存レコードの取り込み

zone にすでにあるレコードは、Terraform に取り込んでから管理します。
取り込まずに同じレコードを宣言すると、apply が重複エラーで失敗します。

```sh
cf-terraforming generate --resource-type cloudflare_dns_record --zone <ZONE_ID>
cf-terraforming import --resource-type cloudflare_dns_record --zone <ZONE_ID> --modern-import-block
```

出力された `resource` と `import` ブロックを `terraform/` に置き、PR の plan で差分が import だけであることを確認してから merge します。
DNSSEC の設定は `cloudflare_zone_dnssec.abyss0` で管理し、現在は `disabled` を宣言しています。

## コマンド

```sh
mise install
mise run tf:fmt     # 整形
mise run tf:check   # fmt、init（backend なし）、validate
mise run tf:lock    # provider の checksum を更新
```

provider を更新したら `mise run tf:lock` を実行し、`.terraform.lock.hcl` をコミットしてください。
