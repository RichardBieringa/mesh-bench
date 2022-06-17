# Manifests

Contains kubernetes manifests to install required components for service mesh benchmarking.

## Set up namespaces

```sh
# set-up benchmark namespaces
kubectl create ns benchmark
kubectl label namespace benchmark linkerd.io/inject=enabled
kubectl label namespace benchmark istio-injection=enabled

# Add automatic sidecar injection patterns
kubectl label namespace bench-linkerd  linkerd.io/inject=enabled
kubectl label namespace bench-istio istio-injection=enabled

```

## Installation Guide

```sh
helm install metrics-server --namespace kube-system ./metrics-server
helm install monitoring --create-namespace --namespace monitoring ./kube-prometheus-stack
helm install load-generator ./fortio

# Target Servers
helm install target ./fortio --namespace benchmark
helm -n benchmark install target ./fortio
``
