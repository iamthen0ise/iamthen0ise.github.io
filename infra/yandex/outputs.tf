output "bucket" {
  value = yandex_storage_bucket.site.bucket
}

output "website_endpoint" {
  value = "http://${yandex_storage_bucket.site.bucket}.website.yandexcloud.net"
}

output "cdn_cname_target" {
  description = "На это значение ставим CNAME для mirror_cname."
  value       = try(yandex_cdn_resource.site[0].provider_cname, null)
}

output "dns_challenge" {
  description = "Namecheap, стадия 1: CNAME для проверки владения доменом."
  value = [for c in yandex_cm_certificate.mirror.challenges : {
    name  = c.dns_name
    type  = c.dns_type
    value = c.dns_value
  }]
}
