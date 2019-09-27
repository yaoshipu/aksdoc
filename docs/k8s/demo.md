### Daemon set

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-foo
spec:
  selector:
    matchLabels:
      name: ds-foo
  template:
    metadata:
      labels:
        name: ds-foo
    spec:
      tolerations:
      - key: key1
        value: value1
        effect: NoSchedule
      containers:
      - name: nginx
        image: nginx
```