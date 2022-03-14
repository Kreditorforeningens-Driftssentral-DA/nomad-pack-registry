/////////////////////////////////////////////////
// Job
/////////////////////////////////////////////////

variable "job_name" {
  type = string
}

variable "datacenters" {
  type = list(string)
  default = ["dc1"]
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
    target = 5000
  }]
}

/////////////////////////////////////////////////
// Consul Services (main)
/////////////////////////////////////////////////

variable "consul_services" {
  type = list(object({
    name = string
    port = string
    tags = list(string)
    resources = object({
      cpu    = number
      memory = number
    })
    upstreams = object({
      targets    = list(string)
      first_port = number
    })
  }))
}

/////////////////////////////////////////////////
// Task fluentbit
/////////////////////////////////////////////////

variable "resources" {
  description = "The resources to assign the fluentbit task."
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

variable "image" {
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

variable "files" {
  type = list(object({
    name      = string
    b64encode = bool
    content   = string
  }))
}

variable "args" {
  type = list(string)
  default = ["-c", "/fluent-bit/etc/fluent-bit.conf"]
}
