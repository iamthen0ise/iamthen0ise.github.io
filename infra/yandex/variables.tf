variable "cloud_id" {
  type        = string
  description = "ID облака (личный аккаунт)."
  default     = "b1gv6lqc0mdc63qo7bt9"
}

variable "folder_id" {
  type        = string
  description = "ID каталога default (там бакет euvarov и SA gh-deployment)."
  default     = "b1glicpkb45ja5fenv6g"
}

variable "bucket_name" {
  type        = string
  description = "Существующий бакет, импортируется (import-блок в main.tf)."
  default     = "euvarov"
}

variable "mirror_cname" {
  type        = string
  description = "Домен зеркала на CDN. CNAME у регистратора вы добавляете сами."
  default     = "ru.euvarov.me"
}

variable "deployer_sa_name" {
  type        = string
  description = "Существующий сервисный аккаунт для деплоя из GitHub Actions."
  default     = "gh-deployment"
}

variable "create_cdn" {
  type        = bool
  description = "Создавать CDN. false нужен только при первом выпуске сертификата (стадия 1)."
  default     = true
}
