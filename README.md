##Instructions
1. Run `create-credentials.sh` to export credentials from given SA.
2. start machine with `vagrant up`
3. script.sh is run automattically when started.
4. SSH to machine with `vagrant ssh`
5. From the prometheus folder start server with `./prometheus --config.file=config.yaml`
6. Make sure node-exporter, metrics-server and cAdvisor is running in the cluster.
  * Node-exporter can be installed with `helm install -n node-exporter stable/prometheus-node-exporter`
  * Metrics-server can be installed with `helm install -n metrics-server stable/metrics-server`
  * CAdvisor can be installed with the daemon sets manifest `kubectl apply -f cadvisor-ds.yaml`
7. Prometheus can be accessed on <http://192.168.10.40:9090> 
