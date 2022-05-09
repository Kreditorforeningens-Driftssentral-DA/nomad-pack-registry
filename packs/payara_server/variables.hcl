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

variable "region" {
  type = string
}

variable "namespace" {
  type = string
}

/////////////////////////////////////////////////
// GROUP payara
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

variable "ports" {
  type = list(object({
    name   = string
    target = number
    static = number
  }))
  default = [{
    name = "http"
    target = 8080
    static = -1
  },{
    name = "admin"
    target = 4848
    static = -1
  }]
}

variable "ephemeral_disk" {
  type = object({
    migrate = bool
    sticky  = bool
    size    = number
  })
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

//////////////////////////////////
// CONSUL payara
//////////////////////////////////

variable "consul_service" {
  type = object({
    name = string
    port = string
  })
  default = {
    name = "http-payara"
    port = "8080"
  }
}

variable "consul_service_tags" {
  type = list(string)
  default = []
}

variable "consul_service_meta" {
  type = map(string)
  default = {}
}

variable "consul_sidecar_resources" {
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 50
    memory = 50
  }
}

variable "consul_checks" {
  type = list(object({
    name   = string
    port   = string
    path   = string
    expose = bool
  }))
}

variable "consul_upstreams" {
  type = list(object({
    name      = string
    bind_port = number
  }))
}

variable "consul_exposes" {
  type = list(object({
    name = string // Name of the port (will be created)
    port = number // target task-port
    path = string // path to expose
  }))
}

/////////////////////////////////////////////////
// TASK payara
/////////////////////////////////////////////////

variable "payara_image" {
  type = string
  default = "kdsda/payara:5.2022.2-jdk11-main"
}

variable "payara_resources" {
  type = object({
    cpu            = number
    memory         = number
    memory_max     = number
  })
  default = {
    cpu = 100
    memory = 768
    memory_max = 768
  }
}

variable "payara_cpu_hard_limit" {
  type = bool
  default = false
}

variable "payara_artifacts" {
  type = list(object({
    source      = string
    destination = string
    mode        = string
    options     = map(string)
  }))
}

variable "payara_environment_vars" {
  description = "Environment variables."
  type = map(string)
}

variable "payara_environment_file" {
  description = "Environment template-file written to secrets-folder."
  type = string
}

variable "payara_custom_files" {
  description = "Custom file to render at startup."
  type = list(object({
    destination = string
    data        = string
  }))
}

variable "payara_custom_mounts" {
  type = list(object({
    source = string
    target = string
  }))
}

/////////////////////////////////////////////////
// TASK maven
/////////////////////////////////////////////////

variable "task_enabled_maven" {
  type    = bool
  default = false
}

variable "maven_image" {
  type = string
  default = "kdsda/ansible:2022.15"
}

variable "maven_auth" {
  type = object({
    server   = string
    username = string
    password = string
  })
  default = {
    server = "https://repo1.maven.org"
    username = "123"
    password = "123"
  }
}

variable "maven_artifacts" {
  type = list(object({
    repository = string
    name       = string
    group      = string
    extension  = string
    version    = string
  }))
  default = []
}

/////////////////////////////////////////////////
// TASK fluent-bit
/////////////////////////////////////////////////

variable "task_enabled_fluentbit" {
  type = bool
  default = false
}

variable "fluentbit_image" {
  type = string
  default = "fluent/fluent-bit:latest"
}

variable "fluentbit_config" {
  description = "Configurationfile to use at startup."
  type = string
  default = <<-HEREDOC
  # Preferably this should reference e.g. vault and/or consul.
  ---
  service:
    daemon: off
    http_server: off
    flush: 1
    log_level: info
  pipeline:
    inputs:
    - cpu:
        tag: 'demo.cpu'
    outputs:
    - stdout:
        match: '*'
  HEREDOC
}

variable "fluentbit_files" {
  description = "Custom file to render at startup. Reference these from config."
  type = list(object({
    name    = string
    content = string
  }))
  default = []
}
