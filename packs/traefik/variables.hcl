////////////////////////
// Job
////////////////////////

variable "job_name" {
  description = "The name to use as the job name (Default: pack name)."
  type        = string
}

variable "priority" {
  description = "The priority for the job."
  type        = number
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  
  default = ["*"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
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
    value     = "linux",
    operator  = "",
  }]
}

variable "ephemeral_disk" {
  description = "N/A"
  
  type = object({
    sticky  = bool
    migrate = bool
    size    = number
  })

  default = {
    sticky  = true
    migrate = true
    size    = 200
  }
}

////////////////////////
// Network
////////////////////////

variable "network_mode" {
  type    = string
  default = "bridge"
}

variable "ports" {
  description = "Target port to expose on host. Set to -1 to disable."
  
  type = list(object({
    label  = string
    to     = number
    static = number
  }))

  default = [{
    label  = "traefik"
    to     = 8080
    static = 8080
  }, {
    label  = "http"
    to     = 80
    static = 80
  }, {
    label  = "https"
    to     = 443
    static = 443
  }]
}

////////////////////////
// Consul Integration
////////////////////////

variable "consul_services_native" {
  description = "Consul-connect service (native)."
  
  type = list(object({
    port = number
    name = string
    task = string
    tags = list(string)
    meta = map(string)
  }))

  default = []
}

variable "consul_services" {
  description = "Consul-connect services (sidecar)."
  
  type = list(object({
    port   = number
    name   = string
    tags   = list(string)
    meta   = map(string)
    sidecar_cpu = number
    sidecar_memory = number
  }))

  default = []
}

variable "connect_upstreams" {
  description = "Consul-connect upstream services. Attached to the first consul service (sidecar)."

  type = list(object({
    name       = string
    local_port = number
  }))

  default = []
}

variable "connect_exposes" {
  description = "Consul-connect exposed ports. Attached to the first consul service (sidecar)."

  type = list(object({
    port_label = string
    local_port = number
    path       = string
  }))

  default = []
}

////////////////////////
// Task | traefik
////////////////////////

variable "traefik_image" {
  description = "The container image used by the task."
  type        = string
  default     = "traefik:latest"
}

variable "traefik_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  
  default = {
    cpu        = 100
    cpu_strict = false
    memory     = 150
    memory_max = -1
  }
}

variable "traefik_args" {
  description = "Startup arguments."
  type        = list(string)
  
  default = [
    "--accesslog=true",
    "--api=true",
    "--api.dashboard=true",
    "--api.insecure=true",
    "--entrypoints.traefik=true",
    "--entrypoints.traefik.address=:8080",
    "--entrypoints.web=true",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure=true",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.websecure.http.tls=true",
    "--log=true",
    "--log.level=ERROR",
    "--ping=true",
  ]
}

variable "traefik_environment" {
  description = "Will be added to task environment-variables."
  type        = map(string)
  default     = null
}

variable "traefik_mounts" {
  description = "Mount files/folders to running container. Overwrites existing data (adds layer)."
  
  type = list(object({
    source = string
    target = string
  }))

  default = null
}

variable "traefik_files" {
  description = "This string will be written to file at target destination. Setting b64encoded will encrypt the content in job-definition."
  
  type = list(object({
    destination = string
    b64encode   = bool
    data        = string
  }))
}

variable "traefik_files_local" {
  description = "Write files to target destination from local file. Path is relative to working folder. Setting b64encoded will encrypt the content in job-definition."
  
  type = list(object({
    destination = string
    b64encode   = bool
    filename    = string
  }))

  default = []
}

////////////////////////
// Task | fluentbit
////////////////////////

variable "task_fluentbit_enabled" {
  type    = bool
  default = false
}

variable "fluentbit_image" {
  type    = string
  default = "fluent/fluent-bit:latest"
}

variable "fluentbit_args" {
  type    = list(string)
  default = []
}

variable "fluentbit_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })

  default = {
    cpu        = 50
    cpu_strict = false
    memory     = 50
    memory_max = 100
  }
}

variable "fluentbit_config" {
  description = "Configurationfile to use at startup. Uses yml-format"
  type        = string
  
  default = <<-HEREDOC
  ---
  service:
    daemon: off
    flush: 10
    log_level: info
    http_server: off
  pipeline:
    inputs:
    - tail:
        tag: tail.stdin.log
        path: /alloc/logs/traefik.stdin.*
        path_key: filename
        read_from_head: on
        db: /local/stdin.log.db
        db.locking: on
    - tail:
        tag: tail.stderr.log
        path: /alloc/logs/traefik.stderr.*
        path_key: filename
        read_from_head: on
        db: /local/stderr.log.db
        db.locking: on
    outputs:
    - stdout:
        match: '*.stdin.log'
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

