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
    name = "webui"
    target = 8161
    static = -1
  },{
    name = "openwire"
    target = 61616
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
    sidecar_cpu = 100
    sidecar_memory = 128
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
    memory = 512
    memory_max = 512
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
    cpu = 100
    memory = 64
    memory_max = 128
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

variable "adminer_default_server" {
  type = string
  default = "localhost:5432"
}
