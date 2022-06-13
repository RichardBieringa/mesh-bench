# How to perform experiments

# Prepare Environment

```sh
helm install load-generator manifests/fortio
helm install target manifests/fortio
```

# Port forward to load generator

```sh
kubectl port-forward svc/load-generator-fortio 8080:8080
```

# Perform load testing

```sh
curl -s -d '{"url":"http://target-fortio.default.svc.cluster.local:8080", "qps": "-1", "t": "10m", "c": "32"}' "localhost:8080/fortio/rest/run"
``
