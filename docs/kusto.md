# Kusto

### Top queries

```
cluster("Aks").database("AKSccplogs").ControlPlaneEvents 
| where PreciseTimeStamp > ago(2d) 
//| where properties contains "subjectAccessReview" 
//| project PreciseTimeStamp, namespace, Underlay, category, properties 
//| where ['resource-id'] has 'fed757d2-9cb9-490b-bab7-3bdbc397a101'
//| where category == 'kube-apiserver'
| where properties has 'audit.k8s.io/v1beta1'
//| where properties has '9154df03-2a6a-489e-a948-27d6bc45f353'
| extend d = parse_json(properties).log
| take 10
| project PreciseTimeStamp, d, namespace, Underlay, category, properties 
```

```
union cluster("Aks").database("AKSprod").FrontEndContextActivity, cluster("Aks").database("AKSprod").AsyncContextActivity
| where subscriptionID contains ""
| where resourceName contains ""
| where msg contains "intent" or msg contains "Upgrading" or msg contains "Successfully upgraded cluster" or msg contains "Operation succeeded" or msg contains "validateAndUpdateOrchestratorProfile" // or msg contains "unique pods in running state"
| where PreciseTimeStamp > ago(90d)
| project PreciseTimeStamp, operationID, correlationID, msg
```

```
union cluster("Aks").database("AKSprod").FrontEndContextActivity, cluster("Aks").database("AKSprod").AsyncContextActivity
| where PreciseTimeStamp > ago(1d)
| where operationID == "fcc0660c-0569-4baf-a4c7-0c0dd4c6094e"
| project PreciseTimeStamp, level, msg
```

```
cluster("Aks").database("AKSprod").BlackboxMonitoringActivity
| where TIMESTAMP > ago(1d)
| where subscriptionID == "b0949e72-53d0-4b26-8018-04b941d4abef"
| where fqdn == "dxptest-dns-a07628c6.hcp.westeurope.azmk8s.io"
//| where state == "Unhealthy"
| project PreciseTimeStamp, state, provisioningState, reason, agentNodeCount, msg
```

### Resources

> [Basic Scale Upgrade Deploy Troubleshooting](https://supportability.visualstudio.com/AzureContainers/_wiki/wikis/AzureContainers?pagePath=%2FAzure%20Incubation%20Container%20Wiki%2FAKS%2FTSG%2FCannot%20manage%20my%20cluster%2FBasic%20Scale%20Upgrade%20Deploy%20Troubleshooting&pageId=9394&wikiVersion=GBmaster)

