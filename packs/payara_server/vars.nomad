// Example file; defines all variables
/////////////////////////////////////////////////
// SCHEDULING
/////////////////////////////////////////////////

job_name    = "demo-payara"
datacenters = ["dc1"]
region      = "global"
namespace   = "default"
scale       = 1

meta = {
  "deployment-id" = "1981.05.v11"
}

ports = [{
  label = "http"
  to = 8080
  static = -1
},{
  label = "admin-console"
  to = 4848
  static = -1
}]

ephemeral_disk = {
  migrate = false
  sticky  = false
  size    = 300
}

constraints = [{
  attribute = "$${attr.kernel.name}"
  value     = "linux"
  operator  = ""
}]

//////////////////////////////////
// CONSUL payara
//////////////////////////////////

consul_services = [{
  port = 8080
  name = "demo-payara-http"
  tags = ["traefik.enable=false"]
  meta = {
    "metrics_prometheus_port" = "$${NOMAD_HOST_ADDR_prometheus}"
  }
  sidecar_cpu = 50
  sidecar_memory = 50
}]

connect_upstreams = [{
  name = "loki-receiver"
  local_port = 3100
}]

connect_exposes   = [{
  path = "/metrics"
  port_label = "prometheus"
  local_port = 2021
}]

/////////////////////////////////////////////////
// TASK payara
/////////////////////////////////////////////////

payara_image = "kdsda/payara:5.2022.2-jdk11-main"

payara_resources = {
  cpu        = 100
  cpu_strict = false
  memory     = 750
  memory_max = 750
}

payara_artifacts        = []
payara_environment      = {}
payara_environment_file = ""
payara_mounts           = []
payara_files            = []
payara_files_local      = []


/////////////////////////////////////////////////
// TASK maven
/////////////////////////////////////////////////

task_enabled_maven = true

maven_image = "kdsda/ansible:2022.15"

maven_resources = {
  cpu        = 100
  cpu_strict = true
  memory     = 100
  memory_max = 250
}

maven_auth = {
  server   = "https://repo1.maven.org"
  username = "anonymous"
  password = "anonymous"
}

maven_artifacts = []

/////////////////////////////////////////////////
// TASK fluent-bit
/////////////////////////////////////////////////

task_enabled_fluentbit = true

fluentbit_image = "fluent/fluent-bit:latest"

fluentbit_resources = {
  cpu        = 100
  cpu_strict = false
  memory     = 75
  memory_max = 125
}

// https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file
fluentbit_config = <<HEREDOC
---
#env: {}
service:
  flush:       1
  log_level:   warn
  http_server: on
pipeline:
  inputs:
  - cpu:
      tag: demo.logs
  - prometheus_scrape:
      tag: demo.metrics
      host: 127.0.0.1
      port: {{ NOMAD_PORT_http }}
      scrape_interval: 10s
      metrics_path: /metrics
  outputs:
  - stdout:
      match: *.logs
  - loki:
      match: *.logs
      host: {{ NOMAD_UPSTREAM_IP_loki }}
      port: {{ NOMAD_UPSTREAM_PORT_loki }}
      labels: job=payara
  - prometheus_exporter:
      match: *.metrics
      host: 0.0.0.0
      port: {{ NOMAD_HOST_PORT_prometheus }}
      add_label: color blue
HEREDOC

fluentbit_files = []
