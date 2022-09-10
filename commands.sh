#!/usr/bin/env bash

# parameters
resource="key_vault"
resourceGroup="compressor"
deploymentName="compressor-dev"

# az group create \
#   --name myResourceGroup \
#   --location "West Europe"

templateFile="./${resource}/template.json"
devParameterFile="./${resource}/parameters.json"
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroup \
  --template-file $templateFile \
  --parameters $devParameterFile

# resourcelist=$(az deployment group  show --resource-group $resourceGroup --name $deploymentName --query "properties.outputResources[].id" -o tsv)
# for resource in $resourcelist; do az resource delete --ids $resource; done
