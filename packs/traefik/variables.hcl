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
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type = list(string)
  default = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type = string
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type = string
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
    to = 8080
    static = -1
  },{
    label = "http"
    to = 80
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

variable "consul_services_native" {
  description = "Consul-connect native services."
  type = list(object({
    port = number
    name = string
    task = string
    tags = list(string)
    meta = map(string)
  }))
}

variable "consul_services" {
  description = "Consul-connect sidecar services."
  type = list(object({
    port   = number
    name   = string
    tags   = list(string)
    meta   = map(string)
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
// TASK traefik
//////////////////////////////////

variable "traefik_image" {
  description = "The container image used by the task."
  type = string
  default = "traefik:latest"
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
    cpu = 100
    cpu_strict = false
    memory = 150
    memory_max = -1
  }
}

variable "traefik_args" {
  description = "Startup arguments."
  type = list(string)
  default = [
    "--accesslog=true",
    "--api=true",
    "--api.dashboard=true",
    "--api.insecure=true",
    "--entrypoints.WEB=true",
    "--entrypoints.WEB.address=:80",
    "--entrypoints.WEB.forwardedheaders.insecure=true",
  ]
}

variable "traefik_environment" {
  description = "Will be added to task environment-variables."
  type = map(string)
}

variable "traefik_mounts" {
  description = "Mount files/folders to running container. Overwrites existing data (adds layer)."
  type = list(object({
    source = string
    target = string
  }))
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
}

//////////////////////////////////
// TASK demo (for testing)
//////////////////////////////////

variable "group_demo_enabled" {
  type = bool
  default = false
}
