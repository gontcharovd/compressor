#!/usr/bin/env bash
location=westeurope
resourceGroupName=compressor

az account set --name compressor
az group delete  --resource-group $resourceGroupName --yes
az keyvault purge --name keyVault7cwkv6diblxjy --location $location 