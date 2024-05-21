variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["*"]
}

variable "namespace" {
  description = "Override default namespace"
  type        = string
}

variable "constraints" {
  description = "Constraints for placing the workloads"
  
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  
  default = []
}

////////////////////////
// Group Variables
////////////////////////

variable "network_mode" {
  description = "N/A"
  type        = string
  default     = "bridge"
}

variable "ports" {
  description = "Ports to expose on host. Set `static = 0` to use a random exposed port in the Nomad range"
  
  type = list(object({
    label  = string
    to     = number
    static = number
  }))

  default  = [{
    label  = "auto"
    to     = 61616
    static = 0
  }, {
    label  = "webui"
    to     = 8161
    static = 0
  }]
}

variable "ephemeral_disk" {
  description = "Persist '/alloc/data' content between allocations."
  
  type = object({
    sticky  = bool   // Try to place new alloc on same host; migrate /local & /alloc/data
    migrate = bool   // Try to migrate data, even if host changes. Implies 'sticy=true'
    size    = number // Size to reserve on host. Not enforced, but used for scheduling
  })
}

////////////////////////
// Service Variables
////////////////////////

variable "services" {
  description = "List of services to register with Consul"

  type = list(object({
    name       = string
    port_label = string
    provider   = string
    tags       = list(string)
    
    checks = list(object({
      name         = string
      type         = string
      path         = string
      port         = number
      interval     = string
      timeout      = string
    }))

    connect_upstreams = list(object({
      name = string
      port = number
    }))
    
    connect_resources = object({
      cpu    = number
      memory = number
    })
  }))
  
  default = [{
    name              = "activemq-auto"
    port_label        = "auto"
    provider          = "consul"
    tags              = ["traefik.enable=false"]
    checks            = []
    connect_upstreams = []
    connect_resources = {
      cpu    = 50
      memory = 64
    }
  }]
}

////////////////////////
// ActiveMQ Task Variables
////////////////////////

variable "activemq_image" {
  type    = string
  default = "ghcr.io/kreditorforeningens-driftssentral-da/container-image-activemq:5.17.1"
}

variable "activemq_resources" {
  description = "N/A"

  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })

  default = {
    cpu        = 100
    cpu_strict = false
    memory     = 512
    memory_max = 1024
  }
}

variable "activemq_env" {
  description = "Environment variables in the task."
  type        = map(string)
}

variable "activemq_files" {
  description = "Render files to '/local', and optionally mount inside container."
  
  type = list(object({
    filename  = string
    mountpath = string
    content   = string
  }))
  
  default = []
}

////////////////////////
// Telegraf Task Variables
////////////////////////

variable "telegraf_enabled" {
  type    = bool
  default = false
}

variable "telegraf_image" {
  type    = string
  default = "telegraf:latest"
}

variable "telegraf_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })

  default = {
    cpu        = 50
    cpu_strict = false
    memory     = 32
    memory_max = 128
  }
}

variable "telegraf_env" {
  description = "Environment variables in the task."
  
  type = map(string)
  
  default = {
    ACTIVEMQ_USERNAME = "admin"
    ACTIVEMQ_PASSWORD = "admin"
    ACTIVEMQ_WEBADMIN = "admin"
  }
}

variable "telegraf_config" {
  description = ""
  
  type = object({
    filename  = string
    mountpath = string
    content   = string
  })
  
  default = {
    filename  = "telegraf.conf"
    mountpath = "/etc/telegraf"
    content = <<-HEREDOC
    [[outputs.prometheus_client]]
      listen = ":9273"
    
    [[inputs.activemq]]
      url = "http://localhost:8161"
      username = "$${ACTIVEMQ_USERNAME}"
      password = "$${ACTIVEMQ_PASSWORD}"
      webadmin = "$${ACTIVEMQ_WEBADMIN}"
    HEREDOC
  }
}

////////////////////////
// Fluent-Bit  Task Variables
////////////////////////

variable "fluentbit_enabled" {
  type    = bool
  default = false
}

variable "fluentbit_image" {
  type    = string
  default = "fluent/fluentbit:latest"
}

variable "fluentbit_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })

  default = {
    cpu        = 50
    cpu_strict = false
    memory     = 32
    memory_max = 64
  }
}

variable "fluentbit_env" {
  description = "Environment variables in the task."
  type        = map(string)
}

variable "fluentbit_config" {
  type = object({
    filename  = string
    mountpath = string
    content   = string
  })

  default = {
    filename  = "fluentbit.yml"
    mountpath = "/etc/fluentbit"
    content = <<-HEREDOC
    service:
      daemon: off
      http_server: off
      flush: 5
      log_level: error

    pipeline:
      inputs:
      - name: prometheus_scrape
        tag: activemq.prometheus
        host: localhost
        port: 9273
        metrics_path: /metrics
        scrape_interval: 10s
      
      outputs:
      - name: stdout
        match: '*.prometheus'
    HEREDOC
  }
}

variable "fluentbit_args"  {
  description = "N/A"
  type        = list(string)
  
  default = [
    "/fluent-bit/bin/fluent-bit",
    "-c", "/etc/fluentbit/fluentbit.yml",
  ]
}