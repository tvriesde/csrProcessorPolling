az deployment group create --debug\
  --name csrprocessorpolling-subscriptions \
  --resource-group rg-csrprocessorpolling-dev-westeurope \
  --template-file eventSubscriptions/main.bicep \
  --parameters eventSubscriptions/params/dev.bicepparam