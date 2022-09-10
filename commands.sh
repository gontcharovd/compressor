#!/usr/bin/env bash

# parameters
resourceGroup="compressor"
deploymentName="compressor-dev"
templateFile="./container_registry/template.json"
devParameterFile="./container_registry/parameters.json"

# az group create \
#   --name myResourceGroup \
#   --location "West Europe"

# az deployment group create \
#   --name $deploymentName \
#   --resource-group $resourceGroup \
#   --template-file $templateFile \
#   --parameters $devParameterFile

resourcelist=$(az deployment group  show --resource-group $resourceGroup --name $deploymentName --query "properties.outputResources[].id" -o tsv)
for resource in $resourcelist; do az resource delete --ids $resource; done
