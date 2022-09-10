#!/usr/bin/env bash

# parameters
resource="key_vault"
templateFile="./azure-deploy-compressor-dev.json"
# templateFile=="./${resource}/template.json"
# devParameterFile="./${resource}/parameters.json"
resourceGroup="compressor"
deploymentName="compressor-dev"

# az group create \
#   --name $resourceGroup \
#   --location "West Europe"

az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroup \
  --template-file $templateFile #\
  # --parameters $devParameterFile

# resourcelist=$(az deployment group  show --resource-group $resourceGroup --name $deploymentName --query "properties.outputResources[].id" -o tsv)
# for resource in $resourcelist; do az resource delete --ids $resource; done
