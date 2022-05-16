# Manifests

Contains kubernetes manifests to install required components for service mesh benchmarking.

## Installation Guide

```sh
helm install metrics-server --namespace kube-system ./metrics-server
helm install monitoring --create-namespace --namespace monitoring ./kube-prometheus-stack
helm install load-generator ./fortio
``
