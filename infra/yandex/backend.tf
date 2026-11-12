terraform {
  # State в Yandex Object Storage. Ключи не в коде: backend.hcl (в .gitignore),
  # см. backend.hcl.example и README.md.
  backend "s3" {
    bucket = "euvarov-tfstate"
    key    = "site-mirror/terraform.tfstate"
    region = "ru-central1"

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    use_lockfile                = true # блокировка файлом рядом со state
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
