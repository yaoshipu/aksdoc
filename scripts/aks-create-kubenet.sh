#!/bin/bash

SEQ=`date +"%Y%m%d%H%M"` 
DEFAULT_RG_NAME="rg-$SEQ"
DEFAULT_CLUSTER_NAME="cluster-$SEQ"

read -p "Enter resource group name [$DEFAULT_RG_NAME]: " RG_NAME
RG_NAME=${RG_NAME:-$DEFAULT_RG_NAME}

read -p "Enter resource group name [$DEFAULT_CLUSTER_NAME]: " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-$DEFAULT_CLUSTER_NAME}

read -p "Enter node count [3]: " NODE_COUNT
NODE_COUNT=${NODE_COUNT:-3}

read -p "Enter node vm size [Standard_B2s]: " NODE_VM_SIZE
NODE_VM_SIZE=${NODE_VM_SIZE:-Standard_B2s}

VNET_NAME=$SEQ-vnet

SUBNET_NAME=$SEQ-subnet

echo ">>> Create a resource group"
az group create --name $RG_NAME --location westus --query id --output tsv

echo ">>> Create a virtual network and subnet"
VNET_RESP=$(az network vnet create \
    --resource-group $RG_NAME \
    --name $VNET_NAME \
    --address-prefixes 192.168.0.0/16 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix 192.168.1.0/24)

VNET_ID=$(echo $VNET_RESP | jq -r '.newVNet.id')
SUBNET_ID=$(echo $VNET_RESP | jq -r '.newVNet.subnets | .[0].id')

echo "$VNET_ID"
echo "$SUBNET_ID"

echo ">>> Create a service principal"
NEW_SP=$(az ad sp create-for-rbac --output json)

echo ">>> Waiting for service principal to propagate"
sleep 10

SP_ID=$(echo $NEW_SP | jq -r .appId)
SP_PASSWORD=$(echo $NEW_SP | jq -r .password)

echo ">>> Assign the service principal Contributor permissions to the virtual network resource"
az role assignment create --assignee $SP_ID --scope $VNET_ID --role Contributor

echo ">>> Create AKS cluster"
az aks create \
--resource-group $RG_NAME \
--name $CLUSTER_NAME \
--node-count $NODE_COUNT \
--node-vm-size $NODE_VM_SIZE \
--network-plugin kubenet \
--service-cidr 10.0.0.0/16 \
--dns-service-ip 10.0.0.10 \
--docker-bridge-address 172.17.0.1/16 \
--vnet-subnet-id $SUBNET_ID \
--service-principal $SP_ID \
--client-secret $SP_PASSWORD