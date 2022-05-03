/////////////////////////////////////////////////
// Job
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
// GROUP variables
/////////////////////////////////////////////////

variable "scale" {
  type = number
  default = 1
}

variable "exposed_ports" {
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
  },{
    name = "debug"
    target = 9009
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

/////////////////////////////////////////////////
// CONSUL services
/////////////////////////////////////////////////

variable "consul_services" {
  type = list(object({
    name = string
    port = string
    tags = list(string)
    upstreams = list(object({
      service    = string
      local_port = number
    }))
    sidecar_resources = object({
      cpu    = number
      memory = number
    })
  }))
  default = [{
    name = "http-payara"
    port = "8080"
    tags = ["traefik.enable=false"]
    upstreams = []
    sidecar_resources = {
      cpu = 100
      memory = 128
    }
  }]
}

/////////////////////////////////////////////////
// TASK variables (payara)
/////////////////////////////////////////////////

variable "image" {
  type = string
  default = "kdsda/payara:5.2022.2-jdk11-main"
}

variable "resources" {
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 500
    memory = 512
    memory_max = 512
  }
}

variable "environment_variables" {
  description = "Environment variables."
  type = map(string)
}

variable "environment_file" {
  description = "Environment template-file written to secrets-folder."
  type = string
}

variable "files" {
  description = "Custom file to render at startup. Optionally mount/overwrite files in the container using the 'mount' parameter."
  type = list(object({
    filename = string
    mount    = string
    content  = string
  }))
  default = [{
    filename  = "local/config/info.txt"
    mount = "/tmp/info.txt"
    content = <<-HEREDOC
    This is just an example file, rendered to {{ env "NOMAD_TASK_DIR" }}/config/info.txt.
      - If "mount" is defined, the file will be mounted to specified path inside container image.
    Examples:
      - NOMAD_JOB_NAME = {{ env "NOMAD_JOB_NAME" }}
      - 1 x $ with {} = Not allowed (ref. to variables when using packs)
      - 2 x $ with {} = $${NOMAD_JOB_NAME} > pass to nomad-server for substitution at runtime
      - 3 x $ with {} = $$${NOMAD_JOB_NAME} > write literal "$" in rendered file
    Preferably this should reference e.g. vault and/or consul.
    HEREDOC
  }]
}

/////////////////////////////////////////////////
// TASK variables (maven)
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
// TASK variables (fluent-bit)
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
