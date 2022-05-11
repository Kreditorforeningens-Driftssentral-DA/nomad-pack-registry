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
    operator  = string
    value     = string
  }))
  default = [{
    attribute = "$${attr.kernel.name}",
    value = "linux",
    operator = "",
  }]
}

variable "ports" {
  description = "Target port to expose on host. Set to -1 to disable."
  type    = list(object({
    label  = string
    to     = number
    static = number
  }))
  default = [{
    label = "console"
    to = 3000
    static = -1
  }]
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

variable "consul_services" {
  description = "Consul-connect sidecar services."
  type = list(object({
    port = number
    name = string
    tags = list(string)
    sidecar_cpu = number
    sidecar_memory = number
  }))
}

variable "connect_upstreams" {
  type = list(object({
    name       = string
    local_port = number
  }))
}

variable "connect_exposes" {
  type = list(object({
    port_label = string
    local_port = number
    path       = string
  }))
}


//////////////////////////////////
// TASK grafana
//////////////////////////////////

variable "grafana_image" {
  description = "The container image used by the task."
  type = string
  default = "grafana/grafana:latest"
}

variable "grafana_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    cpu_strict = false
    memory = 384
    memory_max = -1
  }
}

variable "grafana_environment" {
  description = "Will be added to task environment-variables."
  type = map(string)
  default = {
    GF_PATHS_CONFIG       = "/local/grafana.default.ini"
    GF_PATHS_PROVISIONING = "/local/provisioning"
    GF_PATHS_DATA         = "/local/grafana"
    GF_INSTALL_PLUGINS    = "grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel"
  }
}

variable "grafana_mounts" {
  type = list(object({
    source = string
    target = string
  }))
  default = [{
    source = "local/grafana.ini"
    target = "/etc/grafana/conf/grafana.ini"
  }]
}

variable "grafana_files" {
  description = "This string will be written to file at target destination. Setting b64encoded will encrypt the content in job-definition."
  type = list(object({
    destination = string
    b64encode   = bool
    data        = string
  }))
  default = [{
    destination = "/local/grafana.default.ini"
    b64encode = false
    data = <<-EOH
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

variable "grafana_files_local" {
  description = "Write files to target destination from local file. Path is relative to working folder. Setting b64encoded will encrypt the content in job-definition."
  type = list(object({
    destination = string
    b64encode   = bool
    filename    = string
  }))
}

