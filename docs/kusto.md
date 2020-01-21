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


## ACI

```bash
let resourceUri = "/subscriptions/b15ae5d0-8f07-4cfb-aca3-508d38e9d983/resourceGroups/t-to-tstar-rg/providers/Microsoft.ContainerInstance/containerGroups/aciservice1";
cluster('accprod.kusto.windows.net').database('accprod').HttpIncomingRequests
| where PreciseTimeStamp > datetime(2019-9-1)
| where targetUri contains "australiaeast"
| where targetUri contains "ContainerInstance"
| where subscriptionId == split(resourceUri, "/")[2]
//| where targetUri contains resourceUri
| extend container = extract("/containerGroups/([a-zA-Z0-9-]+)?", 1, targetUri)
//| where targetUri contains container
| where httpMethod in ("PUT","DELETE")
| where httpStatusCode != -1
| project PreciseTimeStamp, httpMethod, container, httpStatusCode, errorMessage
```

```
let resourceUri = "/subscriptions/f4a777ae-540c-4214-ac89-6806513322a7/resourceGroups/bonsai-dev-ext-sim/";
HttpIncomingRequests
| where PreciseTimeStamp > datetime(2019-08-05)
| where subscriptionId == split(resourceUri, "/")[2]
| where targetUri contains resourceUri
| extend container = extract("/containerGroups/([a-zA-Z0-9-]+)?", 1, targetUri)
| where httpMethod in ("PUT","DELETE")
| where httpStatusCode != -1
//| where httpStatusCode == 500
| project PreciseTimeStamp, correlationId, httpMethod, container, httpStatusCode, errorMessage
 
let resourceUri = "/subscriptions/208f934a-7d49-40af-8b08-e1ec8c4e538d/resourceGroups/nr-rg-dev-poc/providers/Microsoft.ContainerInstance/containerGroups/nr-container-dataservicelayer";
SubscriptionDeployments
| where PreciseTimeStamp > datetime(2019-08-05)
| where subscriptionId == split(resourceUri, "/")[2]
| extend container = extract("/containerGroups/([a-zA-Z0-9-]+)?", 1, resourceUri)
| where containerGroup =~ container
| project PreciseTimeStamp, TaskName, ActivityId, correlationId, clusterId, node, clusterDeploymentName, resourceGroup, containerGroup, containers, restartPolicy, duration, ipAddress, fqdn, extensions, dnsConfig, networkProfile, managedIdentity, serviceName, SourceNamespace, userAgent
 
let resourceUri = "/subscriptions/f4a777ae-540c-4214-ac89-6806513322a7/resourceGroups/bonsai-dev-ext-sim/";
SubscriptionDeploymentEvents
| where PreciseTimeStamp >= datetime(2019-09-29) 
| where subscriptionId == split(resourceUri, "/")[2]
| where containerGroup =~ extract("/containerGroups/([a-zA-Z0-9-]+)?", 1, resourceUri)
| project PreciseTimeStamp, ActivityId, correlationId, clusterId, reason, message, type
 
ClusterHealth
| where PreciseTimeStamp > ago(10m) //Increase time to see state changes
| where clusterId in("caas-prod-eastus2euap-linux-04")
| summarize stateChange=max(PreciseTimeStamp) by clusterId, ['state'], provisioningState, networkPolicy, isApiServerHealthy, isMonitoringAgentHealthy, isAzsecpackHealthy, isEtcdHealthy, isDnsHealthy, isSchedulerHealthy, isAzureDNCHealthy, isVNetCustomControllerHealthy, isBridgeHealthy, isControllerManagerHealthy, isMetricsServerHealthy, isProxyHealthy, isServiceActivatorHealthy

// MSI issues
LoggingAgentLogsEvent
| where ['time'] > datetime(2019-08-09 02:00) and ['time'] < datetime(2019-08-09 2:15)
| where container == "msi-connector"
| where Tenant == "caas-prod-westus-linux-54"
| project ['time'],container,message,Tenant,RoleInstance,MachineName,PreciseTimeStamp
| limit 1000
 
// Container move (repair)
JobTraces
| where PreciseTimeStamp >= datetime(2019-06-07 20:00:00) 
| where message contains "caas-2c6f59aa08a54271b44706e16e5a1e17"
| where jobId contains "Repair"
| project PreciseTimeStamp, message
 
// Cleanup failure
JobTraces
| where jobId == "SubscriptionDeploymentConsistencyJob-SIBYL:3A5FANALYTICS:3A5FRG-MAESTRO:3A2DLIVE-WESTEUROPE-CAASPRODWESTEUROPELINUX0|61053C062A09345D"
| project PreciseTimeStamp, message, exception
 
// Billing
union SubscriptionDeployments, BillingUsageEvents
| where PreciseTimeStamp >= datetime(06/12/2019 00:00:00) and PreciseTimeStamp <= datetime(2019-06-13 08:41:15.9213795)
| where subscriptionId == "c1bd9039-9169-41b6-9b75-6eef04aaf8a4"
| where resourceGroup == "credscanacrtest4" or resourceUri contains "credscanacrtest4"
| where containerGroup == "credscanaci99" or resourceUri contains "credscanaci99"
| extend usageDateTime=iif(notempty(eventDateTime), todatetime(eventDateTime), PreciseTimeStamp)
| project usageDateTime, TaskName, quantity, meterType
 
// Runner
SubscriptionDeployments
| where PreciseTimeStamp > ago(3d)
| where resourceGroup contains "CaasRunner-Vnet"
| where clusterId contains "caas-prod-eastus2euap"
| summarize by clusterId, resourceGroup
 
// Slow deployment delete
JobTraces
| where PreciseTimeStamp > datetime(2019-09-23)
| where jobId contains "SubscriptionDeploymentDeletionJob"
| where operationName == "ProviderJobCallback.OnExecutionResult"
| summarize max(PreciseTimeStamp), min(PreciseTimeStamp), count() by jobId
| where max_PreciseTimeStamp > ago(10m) and min_PreciseTimeStamp < ago(1d)
| order by count_ desc
```


## ACR

```bash
cluster("acr").database("acrprod").RegistryActivity
| where TIMESTAMP > ago(1d)
//| where TIMESTAMP  > datetime(2019-11-01 00:00) and TIMESTAMP < datetime(2019-11-01 23:59)
| where http_request_host == "titanufcdevregistry.azurecr.io"
| where message == "fe_request_stop"
| where http_response_status != "200"
//| where http_request_uri contains "saw"
//| project PreciseTimeStamp, http_request_method, http_request_uri, http_response_status, auth_user_name, http_request_useragent
| sort by PreciseTimeStamp asc
//| count  
```

## Remediation

Execute: [Web] [Desktop] https://armprod.kusto.windows.net/ARMProd 
database("ARMProd").HttpIncomingRequests
| where subscriptionId contains "b4d9241b-9038-4021-a4d8-7af80d7e51a2" and targetUri contains "MC_rg-rrh-mvp-baseline_rrh-mvp-baseline_westeurope" and targetUri contains "RESTART"
| where PreciseTimeStamp > ago (5d)
| project TIMESTAMP,TaskName,operationName,httpMethod,targetUri,userAgent,correlationId
 
							
	TIMESTAMP	TaskName	operationName	httpMethod	targetUri	userAgent	correlationId
	2019-09-20 19:51:54.6638586	HttpIncomingRequestStart	POST/SUBSCRIPTIONS/RESOURCEGROUPS/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINES/RESTART	POST	https://management.azure.com:443/subscriptions/b4d9241b-9038-4021-a4d8-7af80d7e51a2/resourceGroups/MC_rg-rrh-mvp-baseline_rrh-mvp-baseline_westeurope/providers/Microsoft.Compute/virtualMachines/aks-rrhbaseline-18638414-1/restart?api-version=2018-04-01	microsoft.com/aks-remediator	24badb2b-7369-4909-bf54-b810d9eb0f40
 
 
To see the reason use this :
 
Execute: [Web] [Desktop] https://aks.kusto.windows.net/AKSprod 
database("AKSprod").RemediatorEvent
| where subscriptionID contains "b4d9241b-9038-4021-a4d8-7af80d7e51a2"  and remediation contains "restart"
| where PreciseTimeStamp > ago (5d)
| project PreciseTimeStamp,level,msg,reason,['state'],remediation
						
	PreciseTimeStamp	level	msg	reason	state	remediation
	2019-09-20 20:53:10.0000000	error	Remediation failed: remediation (CustomerLinuxNodesNotReady) for cluster (5d555e316f175b0001a6cc49) has run too recently	CustomerLinuxNodesNotReady	Unhealthy	restartNotReadyNodes
	2019-09-20 21:05:48.0000000	error	Remediation failed: remediation (CustomerLinuxNodesNotReady) for cluster (5d555e316f175b0001a6cc49) has run too recently	CustomerLinuxNodesNotReady	Unhealthy	restartNotReadyNodes
	2019-09-23 08:39:10.0000000	info	Beginning remediation targeted to node aks-rrhtest-25033075-3 on 5d249c9b009f920001eca4b5 due to CustomerNodeKubeProxyStale	CustomerNodeKubeProxyStale	Unhealthy	restartAgentNodeKubeProxy
	2019-09-23 08:39:10.0000000	info	Remediation complete	CustomerNodeKubeProxyStale	Unhealthy	restartAgentNodeKubeProxy
	2019-09-23 08:39:11.0000000	info	Remediation for CustomerNodeKubeProxyStale on 5d249c9b009f920001eca4b5 completed	CustomerNodeKubeProxyStale	Unhealthy	restartAgentNodeKubeProxy

https://docs.microsoft.com/en-us/azure/aks/support-policies#aks-support-coverage-for-worker-nodes