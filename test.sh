#!/usr/bin/env bash

storageAccountName="compressormi"
AZ_SCRIPTS_OUTPUT_PATH="./output.json"

blob_name=$(az storage blob list --container-name postgres-database-dump --account-name $storageAccountName --query [0].name)
echo "blob name: ${blob_name}"
jq -n --arg blob $blob_name '{ "result": $blob }' | tee $AZ_SCRIPTS_OUTPUT_PATH

keyVaultName=keyVaultCompressor1994
export PGPASSWORD=$(az keyvault secret show --name postgresPassword --vault-name $keyVaultName --query value)
echo $PGPASSWORD