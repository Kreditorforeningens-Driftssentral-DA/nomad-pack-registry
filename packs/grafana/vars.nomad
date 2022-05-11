job_name = "demo-grafana"

consul_services = [{
  port = "3000"
  name = "grafana-console"
  tags = ["traefik.enable=false"]
  meta = {
    metrics_enabled = "false"
    metrics_nomad_port = "$${NOMAD_HOST_IP_console}"
    metrics_nomad_path = "/metrics"
  }
  sidecar_cpu = 50
  sidecar_memory = 50
}]

connect_upstreams = [{
  name = "loki"
  local_port = 5000
},{
  name = "mimir"
  local_port = 5001
},{
  name = "prometheus"
  local_port = 5002
}]

/*
grafana_files_local = [{
  destination = "/local/grafana-example.ini"
  b64encode = true
  filename = "packs/grafana/examples/grafana.ini"
}]

connect_exposes = [{
  port_label = "metrics"
  path = "/metrics"
  local_port = 3000
}]
*/