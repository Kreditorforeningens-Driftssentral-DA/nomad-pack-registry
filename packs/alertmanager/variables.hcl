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
    label  = string
    to     = number
    static = number
  }))
  default = [{
    label = "http"
    to = 9093
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
// TASK alertmanager
/////////////////////////////////////////////////

variable "alertmanager_image" {
  type = string
  default = "prom/alertmanager:latest"
}

variable "alertmanager_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    cpu_strict = false
    memory = 100
    memory_max = -1
  }
}

variable "alertmanager_args" {
  type = list(string)
  default = [
    "--config.file=/etc/alertmanager/alertmanager.yml",
    "--data.retention=24h",
    "--web.listen-address=:9093",
    "--log.level=info",
  ]
}

variable "alertmanager_mounts" {
  type = list(object({
    source = string
    target = string
  }))
  default = [{
    source = "local/alertmanager.yml"
    target = "/etc/alertmanager/alertmanager.yml"
  }]
}

variable "alertmanager_files" {
  type = list(object({
    destination = string
    b64encode   = bool
    data        = string
  }))
  default = [{
    destination = "/local/alertmanager.yml"
    b64encode = false
    data = <<-HEREDOC
    ---
    route:
      group_by: [ "alertname" ]
      receiver: empty # default receiver

    receivers:
    - name: empty
    HEREDOC
  }]
}

variable "alertmanager_files_local" {
  type = list(object({
    destination = string
    b64encode   = bool
    filename    = string
  }))
}

/////////////////////////////////////////////////
// TASK prom2teams
/////////////////////////////////////////////////

variable "prom2teams_enabled" {
  type = bool
  default = false
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
    cpu = 100
    cpu_strict = false
    memory = 100
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
    "--configpath","/opt/prom2teams/config.ini",
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

variable "prom2teams_files_local" {
  type = list(object({
    destination = string
    b64encode   = bool
    filename    = string
  }))
}
