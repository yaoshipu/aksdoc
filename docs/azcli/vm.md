## Azure VM CLI

#### Create VM

```bash
az vm create -n MyVm2 \
    -g MyResourceGroup \
    --image Canonical:UbuntuServer:16.04.0-LTS:16.04.201906280 \
    --size Standard_B1s \
    --location westus \
    --admin-username azuser \
    --ssh-key-values ~/.ssh/spark_rsa.pub
```

?> For more use cases, click [az vm create](https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create).


#### List VM images
```bash
az vm image list --offer UbuntuServer --all --query '[*].urn' -o tsv
```

?> For more information, head over to the [offical documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage).


##### Ubuntu images

`Canonical:UbuntuServer:12.04.5-LTS:12.04.201705020`

`Canonical:UbuntuServer:14.04.5-LTS:14.04.201905140`

`Canonical:UbuntuServer:16.04.0-LTS:16.04.201906280`

`Canonical:UbuntuServer:18.04-LTS:18.04.201907221`

##### Other OS images
`CentOS`, `CoreOS`, `Debian`, `openSUSE-Leap`, `RHEL`, `SLES`, `UbuntuLTS`, `Win2019Datacenter`,`Win2016Datacenter`, `Win2012R2Datacenter`, `Win2012Datacenter`, `Win2008R2SP1`.   

#### List VM sizes
```bash
az vm list-sizes -l westus --output table 
# az vm list-sizes -l westus --query '[*].name' # list names only
```

#### Get VM private ip
```bash
az vm show -d -g MyKube -n worker-0 --query privateIps -o tsv
```

#### Get VM public ip
```bash
az vm show -d -g MyKube -n worker-0 --query publicIps -o tsv
```