#!/bin/bash
version=2.9.2
directory=prometheus-${version}
master_ip=192.168.10.10
#wget https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz
#mkdir $directory
#sudo tar xvfz prometheus-*.tar.gz -C $directory --strip-components 1
#cd $directory

cat > prometheus.yml <<EOF
# Prometheus configuration to scrape Kubernetes outside the cluster
# Change master_ip and api_password to match your master server address and admin password
global:
  scrape_interval:     15s
  evaluation_interval: 15s


scrape_configs:
# metrics for the prometheus server
- job_name: 'prometheus'
  static_configs:
    - targets: ['localhost:9090']

# metrics for default/kubernetes api's from the kubernetes master
- job_name: 'kubernetes-apiservers'
  kubernetes_sd_configs:
  - role: endpoints
    api_server: https://${master_ip}
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: admin
      password: api_password
  scheme: https
  tls_config:
    insecure_skip_verify: true
  basic_auth:
    username: admin
    password: api_password
  relabel_configs:
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: default;kubernetes;https

# metrics for the kubernetes node kubelet service (collection proxied through master)
- job_name: 'kubernetes-nodes'
  kubernetes_sd_configs:
  - role: node
    api_server: https://${master_ip}
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: admin
      password: api_password
  scheme: https
  tls_config:
    insecure_skip_verify: true
  basic_auth:
    username: admin
    password: api_password
  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - target_label: __address__
    replacement: ${master_ip}:443
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/\${1}/proxy/metrics

# metrics from service endpoints on /metrics over https via the master proxy
# set annotation (prometheus.io/scrape: true) to enable
# Example: kubectl annotate svc myservice prometheus.io/scrape=true
- job_name: 'kubernetes-service-endpoints'
  kubernetes_sd_configs:
  - role: endpoints
    api_server: https://${master_ip}
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: admin
      password: api_password
  scheme: https
  tls_config:
    insecure_skip_verify: true
  basic_auth:
    username: admin
    password: api_password
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
    action: keep
    regex: true
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
    action: replace
    regex: (\d+)
    target_label: __meta_kubernetes_pod_container_port_number
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
    action: replace
    regex: ()
    target_label: __meta_kubernetes_service_annotation_prometheus_io_path
    replacement: /metrics
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_pod_container_port_number, __meta_kubernetes_service_annotation_prometheus_io_path]
    target_label: __metrics_path__
    regex: (.+);(.+);(.+);(.+)
    replacement: /api/v1/namespaces/\$1/services/\$2:\$3/proxy\$4
  - target_label: __address__
    replacement: ${master_ip}:443
  - action: labelmap
    regex: __meta_kubernetes_service_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: kubernetes_name
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: instance

# metrics from pod endpoints on /metrics over https via the master proxy
# set annotation (prometheus.io/scrape: true) to enable
# Example: kubectl annotate pod mypod prometheus.io/scrape=true
- job_name: 'kubernetes-pods'
  kubernetes_sd_configs:
  - role: pod
    api_server: https://${master_ip}
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: admin
      password: api_password
  scheme: https
  tls_config:
    insecure_skip_verify: true
  basic_auth:
    username: admin
    password: api_password
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
    action: keep
    regex: true
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
    action: replace
    regex: ()
    target_label: __meta_kubernetes_pod_annotation_prometheus_io_path
    replacement: /metrics
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_pod_name, __meta_kubernetes_pod_container_port_number, __meta_kubernetes_pod_annotation_prometheus_io_path]
    target_label: __metrics_path__
    regex: (.+);(.+);(.+);(.+)
    replacement: /api/v1/namespaces/\$1/pods/\$2:\$3/proxy\$4
  - target_label: __address__
    replacement: ${master_ip}:443
  - action: labelmap
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_pod_name]
    action: replace
    target_label: kubernetes_pod_name
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: instance
EOF
