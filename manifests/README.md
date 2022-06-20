# Manifests

Contains kubernetes manifests to install required components for service mesh benchmarking.

## Set up namespaces

```sh
# benchmark namespace with labels to enable automatic sidecar injection
kubectl create ns benchmark
kubectl label namespace benchmark linkerd.io/inject=enabled
kubectl label namespace benchmark istio-injection=enabled

# monitoring namespace for kube-prom stack
kubectl create ns monitoring
```

## Installation Guide

```sh
# Kube prometheus stack for monitoring/pod metrics
helm install monitoring --namespace monitoring ./manifests/kube-prometheus-stack

# Installs the load generator and load receiver
helm install load-generator ./manifests/fortio
helm install target --namespace benchmark ./manifests/fortio
``
