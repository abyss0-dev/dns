# Google Hosting owns managed TLS; keep DNS-only for certificate validation
# without adding another TLS termination path.
resource "cloudflare_dns_record" "enrollment" {
  zone_id = local.zone_id
  name    = "enroll.auth.${local.zone_name}"
  type    = "CNAME"
  content = "abyss0-poc-serve-identity.web.app"
  proxied = false
  ttl     = 1
}
