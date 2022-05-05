//////////////////////////////////
// SCHEDULING
//////////////////////////////////

variable "job_name" {
  description = "The name to use as the job name (Default: pack name)."
  type = string
}

variable "priority" {
  description = "The priority for the job."
  type = number
  default = 50
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type = list(string)
  default = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type = string
  default = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type = string
  default = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator = string
    value = string
  }))
  default = [{
    attribute = "$${attr.kernel.name}",
    value = "linux",
    operator = "",
  }]
}

//////////////////////////////////
// GROUP
//////////////////////////////////

variable "http_port" {
  description = "Target port to expose on host. Set to -1 to disable."
  type    = number
  default = 3000
}

variable "ephemeral_disk" {
  description = "N/A"
  type = object({
    sticky  = bool
    migrate = bool
    size    = number
  })
}

//////////////////////////////////
// CONSUL
//////////////////////////////////

variable "consul_service" {
  description = "Consul-connect sidecar services."
  type = object({
    port = number
    name = string
    tags = list(string)
    sidecar_cpu = number
    sidecar_memory = number
    upstreams = list(object({
      service = string
      port = number
    }))
  })
}

//////////////////////////////////
// TASK grafana
//////////////////////////////////

variable "resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 384
    memory_max = 384
  }
}

variable "image" {
  description = "The container image used by the task."
  type = string
  default = "grafana/grafana:latest"
}

variable "environment" {
  type = map(string)
  default = {
    GF_PATHS_CONFIG       = "/local/grafana.ini"
    GF_PATHS_PROVISIONING = "/local/provisioning"
    GF_PATHS_DATA         = "/local/grafana"
    GF_INSTALL_PLUGINS    = "grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel"
  }
}

variable "files" {
  type = list(object({
    target  = string
    content = string
  }))
  default = [{
    target = "/local/grafana.ini"
    content = <<-EOH
      instance_name = grafana
      [security]
        admin_user = grafana
        admin_password = grafana
        disable_initial_admin_creation = false
      [users]
        default_theme = dark
      [date_formats]
        default_timezone = Europe/Oslo
      EOH
  }]
}

variable "mounts" {
  type = list(object({
    type   = string
    source = string
    target = string
  }))
  default = [{
    type   = "bind"
    source = "local/grafana.ini"
    target = "/etc/grafana/conf/grafana.ini"
  }]
}

