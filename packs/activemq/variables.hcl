/////////////////////////////////////////////////
// JOB
/////////////////////////////////////////////////

variable "job_name" {
  type = string
}

variable "datacenters" {
  type = list(string)
}

variable "namespace" {
  type = string
}

/////////////////////////////////////////////////
// GROUP main
/////////////////////////////////////////////////

variable "scale" {
  type = number
  default = 1
}

variable "meta" {
  type = map(string)
  default = {
    "deployment-id" = "0"
  }
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

variable "exposed_ports" {
  type = list(object({
    name   = string
    target = number
    static = number
  }))
  default = [{
    name = "webadmin"
    target = 8161
    static = -1
  }]
}

/////////////////////////////////////////////////
// CONSUL services
/////////////////////////////////////////////////

variable "consul_services" {
  type = list(object({
    name = string
    port = string
    tags = list(string)
    meta = map(string)
    sidecar_cpu    = number
    sidecar_memory = number
    upstreams = list(object({
      name       = string
      local_port = number
    }))
  }))
  default = [{
    name = "amq-openwire"
    port = "61616"
    tags = ["traefik.enable=false"]
    meta = {}
    sidecar_cpu = 100
    sidecar_memory = 64
    upstreams = []
  }]
}

/////////////////////////////////////////////////
// TASK activemq
/////////////////////////////////////////////////

variable "image" {
  type = string
  default = "ghcr.io/kreditorforeningens-driftssentral-da/container-image-activemq:5.17.1"
}

variable "resources" {
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 384
    memory_max = 768
  }
}

variable "environment" {
  type = map(string)
}

variable "files" {
  type = list(object({
    name      = string
    content   = string
  }))
  default = [{
    name = "/local/info.txt"
    content = <<-EOH
    This is just an example file, rendered to {{ env "NOMAD_TASK_DIR" }}/config/info.txt.
    Example: NOMAD_JOB_NAME = {{ env "NOMAD_JOB_NAME" }}
    EOH
  }]
}

variable "mounts" {
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
