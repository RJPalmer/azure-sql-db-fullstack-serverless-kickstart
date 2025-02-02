#!/bin/bash
set -euo pipefail

# Load values from .env file or create it if it doesn't exists
FILE=".env"
if [[ -f $FILE ]]; then
	echo "Loading from $FILE" 
    eval $(egrep "^[^#;]" .env | xargs -d'\n' -n1 | sed 's/^/export /')
else
	cat << EOF > .env
resourceGroup=""
appName=""
location=""

# Connection string
azureSQL='Server=tcp:.database.windows.net,1433;Initial Catalog=todo_v3;Persist Security Info=False;User ID=webapp;Password=Super_Str0ng*P4ZZword!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

gitSource="https://github.com/RJPalmer/azure-sql-db-fullstack-serverless-kickstart"
gitToken="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"
EOF
	echo "Enviroment file not detected."
	echo "Please configure values for your environment in the created .env file"
	echo "and run the script again."
	exit 1
fi

echo "Creating Resource Group...";
az group create \
    -n $resourceGroup \
    -l $location

echo "Deploying Static Web App...";
az deployment group create \
  --name "swa-deploy-3.0" \
  --resource-group $resourceGroup \
  --template-file azure-deploy.arm.json \
  --parameters \
    name=$appName \
    location=$location \
    repositoryToken=$gitToken \
    repositoryUrl=$gitSource \
    branch="v3.0" \
    appLocation="./client" \
    apiLocation="./api" \
    azureSQL="$azureSQL"

echo "Getting Static Web App...";
dhn=`az staticwebapp show -g $resourceGroup -n $appName --query "defaultHostname"`
echo "Static Web App created at: $dhn";

echo "Done."