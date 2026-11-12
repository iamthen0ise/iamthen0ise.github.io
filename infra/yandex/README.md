# Зеркало сайта в Yandex Cloud

Terraform для бакета `euvarov`, сертификата и CDN (`ru.euvarov.me`).
State лежит в бакете `euvarov-tfstate` (версионирование включено, доступ только у SA `tf-state`).

## Работа

```
export YC_TOKEN=$(yc --profile personal iam create-token)   # fish: set -x YC_TOKEN (...)
terraform init -backend-config=backend.hcl
terraform plan
```

Первое развёртывание в две стадии: `terraform apply -var create_cdn=false` (сертификат), добавить
`_acme-challenge.ru` CNAME в Namecheap, дождаться `ISSUED`, затем обычный `terraform apply` (CDN).

## Bootstrap state-бакета (один раз, руками)

```
F=b1glicpkb45ja5fenv6g
yc --profile personal storage bucket create --name euvarov-tfstate --folder-id $F --max-size 1073741824
yc --profile personal storage bucket update --name euvarov-tfstate --versioning versioning-enabled
yc --profile personal iam service-account create --name tf-state --folder-id $F
yc --profile personal resource-manager folder add-access-binding $F \
  --role storage.editor --subject serviceAccount:<id SA tf-state>
yc --profile personal iam access-key create --service-account-name tf-state --folder-id $F
# key_id и secret -> backend.hcl (chmod 600), в git не попадает
```

## CDN: Host для origin (вручную, провайдер не применяет)

Website-эндпоинт выбирает бакет по заголовку Host, поэтому CDN должен слать Host бакета, а не `ru.euvarov.me`.
`custom_host_header` провайдер не применяет (в `main.tf` стоит `ignore_changes`). После (пере)создания ресурса:

```
yc --profile personal cdn resource update --id <resource-id> --host-header euvarov.website.yandexcloud.net
yc --profile personal cdn cache purge --resource-id <resource-id> --path '/*'
```

Без этого зеркало отвечает `404 NoSuchBucket`. Раскатка конфига на узлы занимает 10–20 минут.
