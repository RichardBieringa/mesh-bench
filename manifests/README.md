# Cluster set-up

This contains some instructions in order to install the components and requirements in order to use Mesh Bench.

This assumes you have kubectl and helm installed, and a valid cluster in the current context of your kubectl config.

### Set up namespaces

```sh
# benchmark namespace with labels to enable automatic sidecar injection
kubectl create ns benchmark
kubectl label namespace benchmark linkerd.io/inject=enabled
kubectl label namespace benchmark istio-injection=enabled

# monitoring namespace for kube-prom stack
kubectl create ns monitoring
```

### Installation Guide

```sh
# kube prometheus stack for monitoring/pod metrics
helm install monitoring --namespace monitoring ./manifests/kube-prometheus-stack

# installs the load generator and load receiver
helm install load-generator ./manifests/fortio
helm install target --namespace benchmark ./manifests/fortio
```


### Installing/Switching between Service Meshes


```sh

# Linkerd pre-install
linkerd check --pre
# if fail:
kubectl delete crd trafficsplits.split.smi-spec.io

# Linkerd install
linkerd install  | kubectl apply -f -
linkerd check

# Linkerd uninstall
linkerd uninstall | kubectl delete -f -


# Istio install
istioctl install -y
istioctl verify-install

# Istio uninstall
istioctl x uninstall --purge


# Traefik install
helm install traefik-mesh ./manifests/traefik-mesh/

# Traefik uninstall
helm uninstall traefik-mesh ./manifests/traefik-mesh/


# Cilium install
cilium install --version v1.12.0-rc1 --helm-set enableIngressController=true --kube-proxy-replacement=probe
cilium status

# Cilium uninstall
cilium uninstall
```
