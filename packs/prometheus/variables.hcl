/////////////////////////////////////////////////
// SCHEDULING
/////////////////////////////////////////////////

variable "job_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

variable "datacenters" {
  type = list(string)
  default = ["dc1"]
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

/////////////////////////////////////////////////
// GROUP prometheus
/////////////////////////////////////////////////

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
// CONSUL service (prometheus)
/////////////////////////////////////////////////

variable "consul_service" {
  type = object({
    name = string
    port = string
    tags = list(string)
    meta = map(string)
    expose_check = bool
    sidecar_cpu    = number
    sidecar_memory = number
  })
  default = {
    name = "http-prometheus"
    port = "9090"
    tags = ["traefik.enable=false"]
    meta = {
      "deployment" = "Nomad-Pack"
    }
    expose_check = false
    sidecar_cpu = 100
    sidecar_memory = 32
  }
}

/////////////////////////////////////////////////
// TASK prometheus
/////////////////////////////////////////////////

variable "image" {
  type = string
  default = "prom/prometheus:latest"
}

variable "resources" {
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 64
    memory_max = -1
  }
}

variable "args" {
  type = list(string)
  default = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/local/prometheus",
    "--web.console.libraries=/usr/share/prometheus/console_libraries",
    "--web.console.templates=/usr/share/prometheus/consoles",
  ]
}

variable "config" {
  type = string
  default = <<-HEREDOC
  global:
    scrape_interval: 15s
    scrape_timeout: 5s
  scrape_configs:
  - job_name: self
    metrics_path: /metrics
    static_configs:
    - targets: ["localhost:9090"]
  HEREDOC
}

variable "custom_files" {
  type = list(object({
    destination = string
    data        = string
  }))
  default = []
}

variable "custom_mounts" {
  type = list(object({
    source = string
    target = string
  }))
  default = []
}

