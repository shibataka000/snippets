#!/bin/bash

az group create --name ExampleGroup --location "Japan East"
az group deployment create \
   --name ExampleDeployment \
   --resource-group ExampleGroup \
   --template-file storage.json \
   --parameters storageAccountType=Standard_GRS
