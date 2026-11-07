# Auth0 terminates TLS and binds passkeys to this owned, stable hostname.
# Keep DNS-only: a Cloudflare proxy would introduce another TLS termination path.
resource "cloudflare_dns_record" "auth" {
  zone_id = local.zone_id
  name    = "auth.${local.zone_name}"
  type    = "CNAME"
  content = "dev-bjbcu6mmtbk86c7y-cd-7rseqn5zzqi57rgy.edge.tenants.us.auth0.com"
  proxied = false
  ttl     = 1
}
