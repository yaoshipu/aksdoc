# Reverse SSH Port Forwarding

Reverse SSH Port Forwarding specifies that the given port on the remote server host is to be forwarded to the given host and port on the local side. In short word, Reverse SSH is a technique through which you can access systems that are behind a firewall from the outside world.

### Create a demo resource group

```bash
az group create -l westus -n SSH_DEMO
```

### Create a demo server VM

```bash
az vm create -n myserver \
    -g SSH_DEMO \
    --image UbuntuLTS \
    --size Standard_B1s \
    --location westus \
    --admin-username azuser \
    --ssh-key-values ~/.ssh/spark_rsa.pub
```
```bash
{
  "fqdns": "",
  "id": "/subscriptions/412d1f37-bc7c-422c-bf7e-93099a2feab0/resourceGroups/SSH_DEMO/providers/Microsoft.Compute/virtualMachines/myserver",
  "location": "westus",
  "macAddress": "00-0D-3A-30-05-69",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.5",
  "publicIpAddress": "104.40.91.59",
  "resourceGroup": "SSH_DEMO",
  "zones": ""
}
```
> Note server `publicIpAddress` for SSH login

### Create a demo client VM

```bash
az vm create -n myclient \
    -g SSH_DEMO \
    --image UbuntuLTS \
    --size Standard_B1s \
    --location westus \
    --admin-username azuser \
    --ssh-key-values ~/.ssh/spark_rsa.pub
```

```bash
{
  "fqdns": "",
  "id": "/subscriptions/412d1f37-bc7c-422c-bf7e-93099a2feab0/resourceGroups/SSH_DEMO/providers/Microsoft.Compute/virtualMachines/myclient",
  "location": "westus",
  "macAddress": "00-0D-3A-31-00-E8",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "104.40.12.179",
  "resourceGroup": "SSH_DEMO",
  "zones": ""
}
```
> Note client `publicIpAddress` for SSH login

#### Copy public key to client VM

```bash 
scp ~/.ssh/id_rsa.pub azuser@${myclient_public_ip}:~/.ssh
```

### Login to client VM

```bash
ssh azuser@${myclient_public_ip}
```

```bash
sudo apt update && apt install nginx -y
```

```bash
ssh -i /home/azuser/.ssh/id_rsa \ 
    -fNnT \
    -C \
    -R 9090:localhost:80 azuser@${myserver_public_ip} \
    -p 22 \
    -oServerAliveInterval=1 \
    -oServerAliveCountMax=5 \
    -oControlPath=no \
    -oControlMaster=no \
    -oExitOnForwardFailure=yes
```

Destination (192.168.20.55) <- |NAT| <- Source (138.47.99.99)

?> This command will initiate an ssh connection to remote computer azuser@${myserver_public_ip} and who will listen port 9090 and forwarded any connection back to localhost's port :80.

* `-f`: tells the SSH to background itself after it authenticates, saving you time by not having to run something on the remote server for the tunnel to remain alive.
* `-N`: if all you need is to create a tunnel without running any remote commands then include this option to save resources.
* `-n`: Redirects stdin from /dev/null (actually, prevents reading from stdin).  This must be used when ssh is run in the background.
* `-T`: useful to disable pseudo-tty allocation, which is fitting if you are not trying to create an interactive shell.

#### Login to server VM

```
azuser@myserver:~$ curl localhost:9090
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
Created Time	10/02/2018 22:01:21
Last Modified Time	07/17/2019 04:56:04


