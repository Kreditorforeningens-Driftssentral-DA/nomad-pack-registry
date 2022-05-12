/////////////////////////////////////////////////
// SCHEDULING
/////////////////////////////////////////////////

variable "job_name" {
  type = string
}

variable "datacenters" {
  type = list(string)
  default = ["dc1"]
}

variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

variable "constraints" {
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [{
    attribute = "$${attr.kernel.name}"
    operator = "="
    value = "linux"
  }]
}

variable "instances" {
  type = number
  default = 1
}

variable "ports" {
  type = list(object({
    name   = string
    to     = number
    static = number
  }))
  default = [{
    name = "http"
    to = 9090
    static = -1
  }]
}

variable "ephemeral_disk" {
  type = object({
    size    = number
    migrate = bool
    sticky  = bool
  })
}

/////////////////////////////////////////////////
// CONSUL
/////////////////////////////////////////////////

variable "consul_services" {
  description = "Consul-connect sidecar services."
  type = list(object({
    port = number
    name = string
    tags = list(string)
    meta = map(string)
    sidecar_cpu = number
    sidecar_memory = number
  }))
}

variable "connect_upstreams" {
  description = "Consul-connect upstreams. Attaches to first Consul service."
  type = list(object({
    name       = string
    local_port = number
  }))
}

variable "connect_exposes" {
  description = "Consul-connect exposed paths. Attaches to first Consul service."
  type = list(object({
    port_label = string
    local_port = number
    path       = string
  }))
}

/////////////////////////////////////////////////
// TASK prometheus
/////////////////////////////////////////////////

variable "prometheus_image" {
  type = string
  default = "prom/prometheus:latest"
}

variable "prometheus_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    cpu_strict = false
    memory = 75
    memory_max = 150
  }
}

variable "prometheus_args" {
  type = list(string)
  default = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/local/prometheus",
    "--web.console.libraries=/usr/share/prometheus/console_libraries",
    "--web.console.templates=/usr/share/prometheus/consoles",
  ]
}

variable "prometheus_files" {
  type = list(object({
    destination = string
    b64encode   = bool
    data        = string
  }))
  default = [{
    destination = "/local/prometheus.default.yml"
    b64encode = false
    data = <<-HEREDOC
    ---
    global:
      scrape_interval: 15s
      scrape_timeout: 5s
    scrape_configs:
    - job_name: self
      metrics_path: /metrics
      static_configs:
      - targets: ["localhost:9090"]
    HEREDOC
  }]
}

variable "prometheus_files_local" {
  type = list(object({
    destination = string
    b64encode   = bool
    filename    = string
  }))
}

variable "prometheus_mounts" {
  type = list(object({
    source = string
    target = string
  }))
  default = [{
    source = "local/prometheus.yml"
    target = "/etc/prometheus/prometheus.yml"
  }]
}

