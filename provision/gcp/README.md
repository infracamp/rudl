# Deploy a single node Swarm / Rudl on Google Cloud Platform


## Logging in to your account

Run `gcloud init` and log in to your account using the Web-Browser. (Copy URL to Browser and allow 
access).

## Creating a new deployment

```
gcloud deployment-manager deployments create rudl-demo-single-node --config single-node-cluster.yml
```


## Updating the existing deployment

```
gcloud deployment-manager deployments update rudl-demo-single-node --config single-node-cluster.yml
```

Remember: Instances will not be rebooted.


## Delete the deployment

```
gcloud deployment-manager deployments delete rudl-demo-single-node
```
