#!/usr/bin/env bash
location=westeurope
resourceGroupName=compressor

az account set --name compressor

echo "Deploying Managed Identity"
az deployment group create \
    --resource-group $resourceGroupName \
    --template-file linked-templates/managed-identity/azuredeploy.bicep \
    --parameters managedIdentityName='compressorManagedIdentity'