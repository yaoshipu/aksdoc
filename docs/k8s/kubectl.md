## Kubectl Cheat Sheet

https://kubernetes.io/docs/reference/kubectl/cheatsheet/

#### Run pod

```bash
kubectl run -it --rm utils --image=shipu/ubuntu.utils:18.04 --generator=run-pod/v1
```

#### Fix Helm permission issue

```bash
kubectl create serviceaccount --namespace kube-system tiller

kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

#### Docker registry

```bash
kubectl create secret docker-registry <name> \
    --docker-server=DOCKER_REGISTRY_SERVER \
    --docker-username=DOCKER_USER \
    --docker-password=DOCKER_PASSWORD \
    --docker-email=DOCKER_EMAIL
```