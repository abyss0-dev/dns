# zone は Cloudflare Registrar が所有する。Terraform は参照だけを行い、作成も削除もしない。
data "cloudflare_zone" "abyss0" {
  filter = {
    name = "abyss0.dev"
  }
}

locals {
  zone_id   = data.cloudflare_zone.abyss0.zone_id
  zone_name = data.cloudflare_zone.abyss0.name
}

resource "cloudflare_zone_dnssec" "abyss0" {
  zone_id = local.zone_id
  status  = "active"
}
