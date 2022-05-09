# GPRC Load Testing

To perform gRPC load testing we need to know how the service operates. How the service operates is specified in a proto file where each service and its RPC calls are detailed.

This presents a problem for generic loadtesting of services, since the workload generator know has to know how the service operates.

## Using the GRPC health check service

The gRPC documentation specified the GRPC Health Checking Protocol. A recommended service to implement in any gRPC service. This provides a 'known' gRPC service, which a workload generator can be aware of when evaluating the performance of the gRPC protocol.

[spec](https://github.com/grpc/grpc/blob/master/doc/health-checking.md)

## Using a workload generator to evaluate a gRPC service

[fortio](https://gihub.com/fortio/fortio) is a load testing tool that supports the gRPC protocol. We can test the default health check protocol in the following maner.

```sh
fortio load -grpc HOST:PORT
```
