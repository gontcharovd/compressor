#!/usr/bin/env bash
location=westeurope
resourceGroupName=compressor

echo "Loading secrets from .env file"
export $(grep -v '^#' secrets.env | xargs -0)

az account set --name compressor

echo "Creating resource group"
az group create --location $location --resource-group $resourceGroupName

echo "Deploying resources"
az deployment group create \
    --resource-group $resourceGroupName \
    --template-file main-template/main.bicep \
    --parameters \
        cogniteApiKeyValue=${COGNITE_API_KEY} \
        cogniteClientValue=${COGNITE_CLIENT} \
        cogniteProjectValue=${COGNITE_PROJECT} \
        postgresUserValue=${POSTGRES_USER} \
        postgresPasswordValue=${POSTGRES_PASSWORD} \