## Azure AKS CLI

#### CreateAKS

```bash
#!/bin/bash

RESOURCE_GROUP=RG0921
CLUSTER_NAME=C0921-1

az group create --name $RESOURCE_GROUP --location westus

az aks create \
    --resource-group $RESOURCE_GROUP\
    --name $CLUSTER_NAME \
    --location westus \
    --node-count 2 \
    --node-vm-size Standard_B2s
```

az aks create --resource-group RG0921 --name C0921-1 --node-count 1