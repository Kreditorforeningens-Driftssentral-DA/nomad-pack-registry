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
  static = 8080
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
// CONSUL
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
  local_port = 9090
}]

/////////////////////////////////////////////////
// TASK payara
/////////////////////////////////////////////////

payara_image = "kdsda/payara:5.2022.2-jdk11-main"

payara_resources = {
  cpu        = 750
  cpu_strict = true
  memory     = 500
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
  cpu_strict = false
  memory     = 100
  memory_max = 200
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
service:
  flush:       3
  daemon: off
  log_level:   warn
  http_server: on
pipeline:
  inputs:
  - tail:
      tag: tail.stdout.log
      path: /alloc/logs/payara.stdout.*
      path_key: file
      read_from_head: on
      skip_long_lines: on
      skip_empty_lines: on
      db: /local/stdout.db
      db.locking: on
  - tail:
      tag: tail.stderr.log
      path: /alloc/logs/payara.stderr.*
      path_key: file
      read_from_head: on
      skip_long_lines: on
      skip_empty_lines: on
      db: /local/stderr.db
      db.locking: on
  - prometheus_scrape:
      tag: prometheus.demo.metrics
      host: 127.0.0.1
      port: {{ env "NOMAD_PORT_http" }}
      scrape_interval: 15s
      metrics_path: /metrics
  outputs:
  - loki:
      match: '*.logs'
      host: {{ env "NOMAD_UPSTREAM_IP_loki" }}
      port: {{ env "NOMAD_UPSTREAM_PORT_loki" }}
      labels: job={{ env "NOMAD_JOB_NAME" }}{{ env "NOMAD_ALLOC_ID" }}, job_alloc={{ env "NOMAD_ALLOC_NAME" }}
  - prometheus_exporter:
      match: '*.metrics'
      host: 0.0.0.0
      port: {{ env "NOMAD_HOST_PORT_prometheus" }}
      add_label: nomad_job {{ env "NOMAD_JOB_NAME" }}
      add_label: noad_alloc {{ env "NOMAD_ALLOC_NAME" }}
HEREDOC

fluentbit_files = []
