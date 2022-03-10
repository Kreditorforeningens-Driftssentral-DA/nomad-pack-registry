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
// Group (main)
/////////////////////////////////////////////////

variable "scale" {
  type = number
  default = 1
}

variable "exposed_ports" {
  type = list(object({
    name = string
    target = number
  }))
  default = [{
    name = "http"
    target = 80
  }]
}

/////////////////////////////////////////////////
// Consul Services (main)
/////////////////////////////////////////////////

variable "consul_service" {
  type = object({
    name = string
    port = string
    tags = list(string)
  })
  default = {
    name = "http-example"
    port = "http"
    tags = ["traefik.enable=false"]
  }
}

variable "consul_upstreams" {
  type = object({
    port_start = number
    services   = list(string)
  })
}

variable "consul_sidecar_resources" {
  type = object({
    cpu    = number
    memory = number
  })
}

/////////////////////////////////////////////////
// Task web (main)
/////////////////////////////////////////////////

variable "image" {
  type = string
  default = "nginx:alpine"
}

variable "resources" {
  type = object({
    cpu = number
    memory = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 32
    memory_max = 64
  }
}

variable "files" {
  type = list(object({
    name      = string
    b64encode = bool
    content   = string
  }))
  default = [{
    name = "/local/config/info.txt"
    b64encode = false
    content = <<-EOH
      Hello!
      This is just an example file, rendered to {{ env "NOMAD_TASK_DIR" }}/config/info.txt.
      If you set the 'b64encode' parameter, template functions in file will not be used.
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
    source = "local/config"
    target = "/tmp/config"
  }]
}
