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
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [{
    attribute = "$${attr.kernel.name}"
    value = "linux"
    operator = ""
  }]
}

variable "ephemeral_disk" {
  type = object({
    migrate = bool
    sticky  = bool
    size    = number
  })
}

variable "scale" {
  type = number
  default = 1
}

variable "meta" {
  type = map(string)
  default = {
    "deployment-id" = "1981-05.v11"
  }
}

variable "ports" {
  type = list(object({
    label  = string
    to     = number
    static = number
  }))
  default = [{
    label = "console"
    to = 8161
    static = -1
  }]
}

/////////////////////////////////////////////////
// CONSUL services
/////////////////////////////////////////////////

variable "consul_service" {
  description = "Primary consul service. Handles upstreams and connect-exposes."
  type = object({
    name = string
    port = string
  })
}

variable "consul_tags" {
  description = "Primary consul service tags."
  type = list(string)
}

variable "consul_meta" {
  description = "Primary consul metadata."
  type = map(string)
}

variable "consul_upstreams" {
  description = "Primary consul service upstreams"
  type = list(object({
    name       = string
    local_port = number
  }))
}

variable "consul_exposes" {
  description = "Primary consul service exposes."
  type = list(object({
    path       = string
    local_port = number
    port_label = string
  }))
}

variable "consul_sidecar_resources" {
  description = "Primary consul service resources."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu = 50
    memory = 75
  }
}

variable "consul_services" {
  description = "Extra consul services."
  type = list(object({
    name = string
    port = string
    tags = list(string)
    meta = map(string)
    sidecar_cpu = number
    sidecar_memory = number
  }))
}

/////////////////////////////////////////////////
// TASK activemq
/////////////////////////////////////////////////

variable "activemq_image" {
  type = string
  default = "ghcr.io/kreditorforeningens-driftssentral-da/container-image-activemq:5.17.1"
}

variable "activemq_image_pull" {
  description = "Force pulling new image."
  type = bool
}

variable "activemq_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    cpu_strict = false
    memory = 512
    memory_max = -1
  }
}

variable "activemq_environment" {
  type = map(string)
}

variable "activemq_custom_files" {
  type = list(object({
    name = string
    data = string
  }))
  default = [{
    name = "/local/info.txt"
    data = <<-EOH
    This is just an example file, rendered to {{ env "NOMAD_TASK_DIR" }}/config/info.txt.
    Example: NOMAD_JOB_NAME = {{ env "NOMAD_JOB_NAME" }}
    EOH
  }]
}

variable "activemq_custom_mounts" {
  type = list(object({
    source = string
    target = string
  }))
  default = [{
    source = "local/info.txt"
    target = "/opt/activemq/conf/info.txt"
  }]
}

/////////////////////////////////////////////////
// TASK postgres (local persistence)
/////////////////////////////////////////////////

variable "task_enabled_postgres" {
  type = bool
  default = false
}

variable "postgres_image" {
  type = string
  default = "postgres:latest"
}

variable "postgres_resources" {
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 50
    memory = 64
    memory_max = 64
  }
}

variable "postgres_environment" {
  type = map(string)
  default = {
    POSTGRES_PASSWORD = "activemq"
    POSTGRES_USER = "activemq"
    POSTGRES_DB = "activemq"
    PGDATA = "/alloc/data/pgdata"
  }
}

/////////////////////////////////////////////////
// TASK adminer (database user interface)
/////////////////////////////////////////////////

variable "task_enabled_adminer" {
  type = bool
  default = false
}

variable "adminer_image" {
  type = string
  default = "adminer:standalone"
}

variable "adminer_resources" {
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 50
    memory = 32
    memory_max = 32
  }
}

variable "adminer_default_server" {
  type = string
  default = "localhost:5432"
}

/////////////////////////////////////////////////
// TASK telegraf (metrics)
/////////////////////////////////////////////////

variable "task_enabled_telegraf" {
  type = bool
  default = false
}

variable "telegraf_image" {
  type = string
  default = "telegraf:latest"
}

variable "telegraf_resources" {
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 50
    cpu_strict = false
    memory = 64
    memory_max = 64
  }
}

variable "telegraf_credentials" {
  type = object({
    activemq_username = string
    activemq_password = string
    activemq_webadmin = string
  })
  default = {
    activemq_username = "admin"
    activemq_password = "admin"
    activemq_webadmin = "admin" // ActiveMQ webadmin root path
  }
}

variable "telegraf_config" {
  type = string
  default = <<-HEREDOC
  [[outputs.prometheus_client]]
    listen = ":9273"
  [[inputs.activemq]]
    url = "http://localhost:8161"
    username = "$${ACTIVEMQ_USERNAME}"
    password = "$${ACTIVEMQ_PASSWORD}"
    webadmin = "$${ACTIVEMQ_WEBADMIN}"
  HEREDOC
}
