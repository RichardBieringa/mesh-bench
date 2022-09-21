# Experimentation

In this prototype implementation of Mesh Bench I implemented the experiments in a shell script. This approach was designed to work on my configuration (read: cluster set-up) and depends on certain dependencies and components. These dependencies and components can be found in the [manifests directory](../manifests).

Note: I do not guarantee that something works out of the box. Again, this repository reflects more or less my personal working directory at the time of writing my thesis.


### Modify Experiments

You can change the experiments that are conducted by commenting out the experiment functions in [the experiment script](./experiment.sh).

Furthermore, you can configure certain aspects of each experiment by modifying the variables found at the top of this experiment script.

### Run Experiments

You can run the experiments by invoking the experimentation script.

```sh
./experiments/experiment.sh
```

### Port forward to load generator

The experiment script takes care of port forwarding for you, but if you want to manually run load testing similar to the method found in the experiment script you can use the following:

```sh
kubectl port-forward svc/load-generator-fortio 8080:8080
```

### Perform load testing

After port forwarding you can perform load tests using the REST API of fortio as such:

```sh
curl -s -d '{"url":"http://target-fortio.default.svc.cluster.local:8080", "qps": "-1", "t": "10m", "c": "32"}' "localhost:8080/fortio/rest/run"
``
