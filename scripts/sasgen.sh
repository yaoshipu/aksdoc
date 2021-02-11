#!/bin/bash

#set -ex

location=westus
sku=Standard_LRS
containername=myuploads
end=`date -u -d "7 days" '+%Y-%m-%dT%H:%MZ'`

help() {
  echo "Commands:"
  echo "  new: create a new storage account with a container and genreate a blob SAS URL"
  echo "  sasgen: genreate a new blob SAS URL"
  echo 
  echo "./storage.sh new ResourceGroupName StorageAccountName BlobContainerName"
  echo "Resource group must exist."
  echo ""
  echo "./storage.sh sasgen StorageAccountName BlobContainerName"
  echo "Storage account and cotnainer must exist"
}

sasgen() {
  local accountname=$1
  local containername=$2
  sas=`az storage container generate-sas -n $containername --account-name $accountname --https-only --permissions dlrw --expiry $end -o tsv`
  echo "example upload url:"
  echo  
  echo curl -X PUT -T '$filename' -H \"x-ms-blob-type: BlockBlob\" https://$accountname.blob.core.windows.net/$containername/'$filename'?$sas
  echo
}

if [ $1 == '-h' ];then
  help
  exit 1
fi

if [ $1 == 'sasgen' ];then
  if [ $# == 3 ];then
    sasgen $2 $3
    exit 0
  fi
  help
  exit 1
fi

if [ $1 == 'new' ];then
  if [ $# == 4 ];then
    rgname=$2
    accountname=$3
    containername=$4
  
    az storage account create -n $accountname -g $rgname -l $location --sku $sku
    az storage container create -n $containername --public-access container --account-name $accountname

    sasgen $accountname $containername
    exit 0
  fi

  help()
  exit 1
fi