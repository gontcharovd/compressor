#!/usr/bin/env bash
location=westeurope
resourceGroupName=compressor
keyVaultName=keyVault7cwkv6diblxjy

az account set --name compressor
echo "Deleting resource group"
az group delete --resource-group $resourceGroupName --yes
echo "Purging Key Vault"
az keyvault purge --name ${keyVaultName} --location $location 