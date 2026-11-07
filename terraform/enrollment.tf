# Hosting owns TLS and forwards to the separate IdP coordinator, not the VM API.
# DNS-only preserves Google's certificate validation and the WebAuthn origin.
resource "cloudflare_dns_record" "enrollment" {
  zone_id = local.zone_id
  name    = "enroll.auth.${local.zone_name}"
  type    = "CNAME"
  content = "abyss0-poc-serve-identity.web.app"
  proxied = false
  ttl     = 1
}
