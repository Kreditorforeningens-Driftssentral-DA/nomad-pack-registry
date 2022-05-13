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

variable "scale" {
  type = number
  default = 1
}

variable "meta" {
  type = map(string)
  default = {
    "deployment-id" = "1981.05.v11"
  }
}

variable "ports" {
  type = list(object({
    label  = string
    to     = number
    static = number
  }))
  default = [{
    label = "http"
    to = 8080
    static = -1
  },{
    label = "admin"
    to = 4848
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

variable "consul_services" {
  description = "Consul services."
  type = list(object({
    port = number
    name = string
    tags = list(string)
    meta = map(string)
    sidecar_cpu = number
    sidecar_memory = number
  }))
  default = [{
    port = 8080
    name = "payara-http"
    tags = []
    meta = {}
    sidecar_cpu = 50
    sidecar_memory = 50
  }]
}

variable "connect_upstreams" {
  description = "Consul connect upstreams. Managed by FIRST defined consul service."
  type = list(object({
    name       = string
    local_port = number
  }))
  default = []
}

variable "connect_exposes" {
  description = "Consul connect exposed http-paths. Managed by FIRST defined consul service."
  type = list(object({
    port_label = string
    local_port = number
    path       = string
  }))
  default = []
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
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    cpu_strict = false
    memory = 768
    memory_max = 768
  }
}

variable "payara_artifacts" {
  description = "Download custom artifacts before starting task."
  type = list(object({
    source      = string
    destination = string
    mode        = string
    options     = map(string)
  }))
}

variable "payara_environment" {
  description = "Environment variables."
  type = map(string)
}

variable "payara_environment_file" {
  description = "Environment variables. Written to secrets-folder."
  type = string
}

variable "payara_files" {
  description = "Custom file to render to disk at startup."
  type = list(object({
    destination = string
    b64encode   = bool
    data        = string
  }))
}

variable "payara_files_local" {
  description = "Custom file to render to disk at startup. Reads from local file."
  type = list(object({
    destination = string
    b64encode   = bool
    filename    = string
  }))
}

variable "payara_mounts" {
  description = "Mount/override file(s) to container (adds layer)."
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
  description = "Container image containing Ansible (Core) required."
  type = string
  default = "kdsda/ansible:2022.15"
}

variable "maven_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    cpu_strict = false
    memory = 128
    memory_max = 384
  }
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

variable "fluentbit_resources" {
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
    memory_max = 100
  }
}

variable "fluentbit_config" {
  description = "Configurationfile to use at startup. Uses yml-format (beta)"
  type = string
  default = <<-HEREDOC
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
