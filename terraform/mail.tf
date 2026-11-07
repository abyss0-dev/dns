# abyss0.dev はメールを送受信しない。なりすましを防ぐため、受信も送信も明示的に拒否する。
# メールを使い始めるときは、この3レコードを置き換える。

# RFC 7505 Null MX
resource "cloudflare_dns_record" "null_mx" {
  zone_id  = local.zone_id
  name     = local.zone_name
  type     = "MX"
  content  = "."
  priority = 0
  ttl      = 1
}

resource "cloudflare_dns_record" "spf" {
  zone_id = local.zone_id
  name    = local.zone_name
  type    = "TXT"
  content = "\"v=spf1 -all\""
  ttl     = 1
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = local.zone_id
  name    = "_dmarc.${local.zone_name}"
  type    = "TXT"
  content = "\"v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s\""
  ttl     = 1
}
