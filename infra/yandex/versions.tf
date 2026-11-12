terraform {
  required_version = ">= 1.10" # use_lockfile в s3-бэкенде

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.130"
    }
  }
}

# Авторизация — снаружи, секреты в файлы не пишем:
#   export YC_TOKEN=$(yc --profile personal iam create-token)
#   export YC_CLOUD_ID=...  YC_FOLDER_ID=...   (или переменные ниже)
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}
