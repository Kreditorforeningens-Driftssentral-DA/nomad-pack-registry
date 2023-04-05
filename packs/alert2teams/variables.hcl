////////////////////////
// Scheduling
////////////////////////

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
    operator  = "="
    value     = "linux"
  }]
}

variable "instances" {
  type = number
  default = 1
}

variable "ports" {
  type = list(object({
    label  = string
    to     = number
    static = number
  }))
  
  default = [{
    label  = "http"
    to     = 8083
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

////////////////////////
// Consul Service
////////////////////////

variable "consul_services" {
  description = "Consul-connect sidecar services."
  
  type = list(object({
    port           = number
    name           = string
    tags           = list(string)
    meta           = map(string)
    sidecar_cpu    = number
    sidecar_memory = number
  }))

  default = []
}

variable "connect_upstreams" {
  description = "Consul-connect upstreams. Attaches to first Consul service."
  
  type = list(object({
    name       = string
    local_port = number
  }))

  default = []
}

variable "connect_exposes" {
  description = "Consul-connect exposed paths. Attaches to first Consul service."
  
  type = list(object({
    port_label = string
    local_port = number
    path       = string
  }))

  default = []
}

////////////////////////
// Task | prom2teams
////////////////////////

variable "prom2teams_enabled" {
  type    = bool
  default = true
}

variable "prom2teams_image" {
  type = string
  default = "idealista/prom2teams:latest"
}

variable "prom2teams_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu        = 100
    cpu_strict = false
    memory     = 85
    memory_max = -1
  }
}

variable "prom2teams_environment" {
  type = map(string)
}

variable "prom2teams_args" {
  type = list(string)
  default = [
    "--enablemetrics",
    "--configpath", "/opt/prom2teams/config.ini",
  ]
}

variable "prom2teams_mounts" {
  type = list(object({
    source = string
    target = string
  }))
  default = [{
    source = "local/config.ini"
    target = "/opt/prom2teams/config.ini"
  }]
}

variable "prom2teams_files" {
  type = list(object({
    destination = string
    b64encode   = bool
    data        = string
  }))

  default = [{
    destination = "/local/config.ini"
    b64encode = false
    data = <<-HEREDOC
    # Example config. Replace w/your own
    [Microsoft Teams]
    Connector: https://webhook.office.com/webhookb2/xxx/IncomingWebhook/yyy/zzz
    
    [HTTP Server]
    Host: 0.0.0.0
    Port: 8089
    
    [Log]
    Level: DEBUG
    
    [Teams Client]
    RetryEnable: false
    RetryWaitTime: 60
    MaxPayload: 24KB
    HEREDOC
  }]
}
