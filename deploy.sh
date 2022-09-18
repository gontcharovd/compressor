#!/usr/bin/env bash
location=westeurope
resourceGroupName=compressor

az account set --name compressor
az group create --location $location --resource-group $resourceGroupName
az deployment group create \
    --resource-group $resourceGroupName \
    --template-file main-template/main.bicep