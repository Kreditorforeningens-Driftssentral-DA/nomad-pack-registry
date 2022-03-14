/////////////////////////////////////////////////
// JOB
/////////////////////////////////////////////////

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

/////////////////////////////////////////////////
// GROUP
/////////////////////////////////////////////////

variable "instances" {
  description = "The number of instances to create."
  type = number
  default = 1
}

variable "http_port" {
  description = "Target port to expose on host. Set to -1 to disable."
  type = number
  default = 3000
}

variable "ephemeral_disk" {
  description = ""
  type = object({
    sticky = bool
    migrate = bool
    size = number
  })
}

/////////////////////////////////////////////////
// CONSUL
/////////////////////////////////////////////////

variable "consul_services" {
  description = "Sidecar service for Consul registration."
  type = list(object({
    port = number
    name = string
    tags = list(string)
    cpu = number
    memory = number
    upstream_first_port = number
    upstreams = list(string)
  }))
}

variable "expose_envoy_metrics" {
  description = "Expose prometheus metrics for envoy sidecars via http."
  type = bool
  default = false
}

/////////////////////////////////////////////////
// TASK (grafana)
/////////////////////////////////////////////////

variable "resources" {
  description = "The resources to assign the task."
  type = object({
    cpu = number
    memory = number
    memory_max = number
  })
  default = {
    cpu = 200,
    memory = 256,
    memory_max = 768,
  }
}

variable "image" {
  description = "The container image used by the task."
  type = object({
    name = string
    version = string
  })
  default = {
    name = "grafana/grafana",
    version = "latest",
  }
}

variable "environment" {
  type = map(string)
  default = {
    GF_PATHS_CONFIG       = "$${NOMAD_TASK_DIR}/grafana.ini"
    GF_PATHS_PROVISIONING = "$${NOMAD_TASK_DIR}/provisioning"
    GF_PATHS_DATA         = "$${NOMAD_TASK_DIR}/grafana"
    GF_INSTALL_PLUGINS    = "grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel"
  }
}

variable "files" {
  type = list(object({
    name      = string
    b64encode = bool
    content   = string
  }))
  default = [{
    name = "grafana.ini"
    b64encode = false
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

/////////////////////////////////////////////////
// TASK (fluentbit)
/////////////////////////////////////////////////

variable "fluentbit_enabled" {
  type = bool
  default = false
}

variable "fluentbit_resources" {
  description = "The resources to assign the fluentbit task."
  type = object({
    cpu = number
    memory = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 16
    memory_max = 64
  }
}

variable "fluentbit_image" {
  description = "The container image used by the fluentbit task."
  type = object({
    name = string
    version = string
  })
  default = {
    name = "fluent/fluent-bit"
    version = "latest"
  }
}

variable "fluentbit_files" {
  type = list(object({
    name      = string
    b64encode = bool
    content   = string
  }))
}

variable "fluentbit_args" {
  type = list(string)
  default = ["-c", "/fluent-bit/etc/fluent-bit.conf"]
}
