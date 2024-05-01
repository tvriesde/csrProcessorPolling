az deployment sub create \
  --name csrprocessorpolling \
  --location westeurope \
  --template-file base/main.bicep \
  --parameters base/params/dev.bicepparam