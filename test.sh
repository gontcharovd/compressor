#!/usr/bin/env bash
# val="hello"
# echo "{\"result\": \"${val}\"}" > test.json

storageAccountName="compressormi"
blob_name=$(az storage blob list --container-name postgres-database-dump --account-name $storageAccountName --query [0].name)
AZ_SCRIPTS_OUTPUT_PATH="./output.json"
echo '{"result":' $blob_name'}' > $AZ_SCRIPTS_OUTPUT_PATH