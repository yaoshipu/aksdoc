# How to do tcpdump in AKS

## How to capture VM NIC traffic

- Login to AKS node, switch to root user
    ```bash 
    tcpdump -i eth0 port 80 -w ech0.cap
    ```

## How to capture container NIC traffic
- Get pod name
    ```bash
    kubectl get po
    ```

    ```bash
    -------------------------------------------------------------------------------------------
    NAME                                READY   STATUS    RESTARTS   AGE
    azure-vote-back-847fc9bcb9-svwnp    1/1     Running   0          4d2h
    azure-vote-front-6c4d697f89-hfggj   1/1     Running   0          4d2h
    ```

- Login to AKS node, switch to root user, get docker ID
    ```bash
    root@aks-agentpool-98537448-0:~# docker ps | grep azure-vote-front-6c4d697f89-hfggj
    ```

    ```bash
    ---------------------------------------------------------------------
    b41bf433e144        microsoft/azure-vote-front                                         "/entrypoint.sh /sta…"   4 days ago          Up 4 days                             k8s_azure-vote-front_azure-vote-front-6c4d697f89-hfggj_default_7ebc9982-c54e-11e9-91d3-ae0409254d7b_0
    827f2d4c5426        k8s.gcr.io/pause-amd64:3.1                                         "/pause"                 4 days ago          Up 4 days                               k8s_POD_azure-vote-front-6c4d697f89-hfggj_default_7ebc9982-c54e-11e9-91d3-ae0409254d7b_0
    ```

- Get container PID
    ```bash
    root@aks-agentpool-98537448-0:~# docker inspect b41bf433e144 | grep Pid
    ```

    ```bash
    "Pid": 12107,
    ```

- Find pair id
    ```bash
    nsenter -t 12107 -n ip addr
    ```

    ```bash
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
    3: eth0@if65: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
        link/ether 3e:a0:ac:61:0b:60 brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 10.244.0.62/24 scope global eth0
           valid_lft forever preferred_lft forever
    ```

- Get NIC id
    ```bash
    root@aks-agentpool-98537448-0:~# ip addr | grep ^65
    ```

    ```bash
    65: veth34b795fa@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cbr0 state UP group default
    ```

- Capture packages
    ```bash
    tcpdump -i veth34b795fa port 80 -w veth34b795fa.cap
    ```

## How to scp files


## Resources

https://www.tecmint.com/12-tcpdump-commands-a-network-sniffer-tool/