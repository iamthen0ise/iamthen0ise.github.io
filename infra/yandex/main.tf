# --- Сервисный аккаунт для деплоя: уже существует, только читаем --------------

data "yandex_iam_service_account" "deployer" {
  name      = var.deployer_sa_name
  folder_id = var.folder_id
}

# Сейчас у него storage.uploader (нет delete), а для `sync --delete` нужен editor.
# Статический ключ намеренно НЕ в Terraform: иначе secret_key попадёт в state.
# Его выпускают через `yc iam access-key create` и кладут сразу в GitHub secrets.
# Роль добавляется, существующий uploader не трогаем.
resource "yandex_resourcemanager_folder_iam_member" "deployer_storage" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${data.yandex_iam_service_account.deployer.id}"
}

# --- Бакет: существует, импортируем и включаем статический хостинг ------------

import {
  to = yandex_storage_bucket.site
  id = var.bucket_name
}

resource "yandex_storage_bucket" "site" {
  bucket    = var.bucket_name
  folder_id = var.folder_id
  max_size  = 1073741824 # как сейчас, 1 GiB

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.deployer_storage]
}

# --- Сертификат (Certificate Manager, Let's Encrypt, DNS-проверка) ------------
# Выпускается независимо от CDN: достаточно CNAME для _acme-challenge в Namecheap.

resource "yandex_cm_certificate" "mirror" {
  name      = replace(var.mirror_cname, ".", "-")
  folder_id = var.folder_id
  domains   = [var.mirror_cname]

  managed {
    challenge_type = "DNS_CNAME"
  }
}

# --- Cloud CDN (стадия 2) -----------------------------------------------------

resource "yandex_cdn_origin_group" "site" {
  count = var.create_cdn ? 1 : 0

  name          = "${var.bucket_name}-origin"
  folder_id     = var.folder_id
  provider_type = "ourcdn"

  origin {
    source = "${yandex_storage_bucket.site.bucket}.website.yandexcloud.net"
  }
}

resource "yandex_cdn_resource" "site" {
  count = var.create_cdn ? 1 : 0

  folder_id       = var.folder_id
  cname           = var.mirror_cname
  origin_group_id = yandex_cdn_origin_group.site[0].id
  origin_protocol = "http" # website-endpoint бакета отдаёт только http

  options {
    # Website-эндпоинт выбирает бакет по Host, поэтому Host клиента не пробрасываем.
    forward_host_header    = false
    custom_host_header     = "${var.bucket_name}.website.yandexcloud.net"
    redirect_http_to_https = true
    gzip_on                = true
    edge_cache_settings    = 300
    browser_cache_settings = 300
    ignore_cookie          = true
  }

  ssl_certificate {
    type                   = "certificate_manager"
    certificate_manager_id = yandex_cm_certificate.mirror.id
  }

  # Провайдер всегда помечает custom_host_header как "known after apply" и
  # безуспешно пытается его переприменить. Значение выставлено через yc
  # (yc cdn resource update --host-header ...), не даём Terraform его трогать.
  lifecycle {
    ignore_changes = [options[0].custom_host_header]
  }
}
