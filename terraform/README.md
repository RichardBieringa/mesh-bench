# Cluster Provisioning

[Source](https://www.linode.com/docs/guides/how-to-deploy-an-lke-cluster-using-terraform/)

## Build kube config

```sh
terraform output kubeconfig | sed s/\"//g | base64 -d > ~/.kube/config
```
