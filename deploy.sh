#!/usr/bin/env bash
location=westeurope
resourceGroupName=compressor
keyVaultName=keyVaultCompressor1994

# load secrets
# export $(grep -v '^#' secrets.env | xargs -0)

# az account set --name compressor
# echo "Creating resource group"
# az group create --location $location --resource-group $resourceGroupName

# echo "Deploying Key Vault"
# az deployment group create \
#     --resource-group $resourceGroupName \
#     --template-file main-template/main.keyvault.bicep \
#     --parameters keyVaultName=${keyVaultName} \
#         cogniteApiKeyValue=${COGNITE_API_KEY} \
#         cogniteClientValue=${COGNITE_CLIENT} \
#         cogniteProjectValue=${COGNITE_PROJECT} \
#         postgresUserValue=${POSTGRES_USER} \
#         postgresPasswordValue=${POSTGRES_PASSWORD} \

# echo "Deploying other resources"
# az deployment group create \
#     --resource-group $resourceGroupName \
#     --template-file main-template/main.bicep \
#     --parameters keyVaultName=${keyVaultName}

az deployment group create \
    --resource-group $resourceGroupName \
    --template-file main-template/restore.bicep