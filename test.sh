#!/usr/bin/env bash
# val="hello"
# echo "{\"result\": \"${val}\"}" > test.json

storageAccountName="compressormi"
AZ_SCRIPTS_OUTPUT_PATH="./output.json"

blob_name=$(az storage blob list --container-name postgres-database-dump --account-name $storageAccountName --query [0].name)
echo "blob name: ${blob_name}"
jq -n --arg blob $blob_name '{ "result": $blob }' | tee $AZ_SCRIPTS_OUTPUT_PATH