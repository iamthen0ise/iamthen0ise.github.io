# Зеркало сайта в Yandex Cloud

Terraform для бакета `euvarov`, сертификата и CDN (`ru.euvarov.me`).
State лежит в бакете `euvarov-tfstate` (версионирование включено, доступ только у SA `tf-state`).

## Работа

```
export YC_TOKEN=$(yc --profile personal iam create-token)   # fish: set -x YC_TOKEN (...)
terraform init -backend-config=backend.hcl
terraform plan
```

Стадия 2 (CDN) — после статуса `ISSUED` у сертификата: `terraform apply -var create_cdn=true`.

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
