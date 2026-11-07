terraform {
  required_version = "~> 1.17"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28"
    }
  }

  # R2 の S3 互換 API に state を置く。認証は AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY（R2 API Token）。
  # バケットは Terraform の外で作成する（README 参照）。
  backend "s3" {
    bucket = "abyss0-dns-tfstate"
    key    = "abyss0.dev/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://346f1da346d96a9b0b9e697a64af0e15.r2.cloudflarestorage.com"
    }

    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# 認証は環境変数 CLOUDFLARE_API_TOKEN。
provider "cloudflare" {}
