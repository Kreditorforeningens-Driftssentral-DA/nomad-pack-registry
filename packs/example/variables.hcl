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

variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

/////////////////////////////////////////////////
// GROUP
/////////////////////////////////////////////////


variable "ports" {
  type = list(object({
    label  = string
    to     = number
    static = number
  }))
  default = [{
    label = "http"
    to = 80
    static = -1
  }]
}

/////////////////////////////////////////////////
// CONSUL
/////////////////////////////////////////////////

variable "consul_service" {
  type = object({
    name    = string
    port    = string
    connect = bool
  })
  default = {
    name = "http-nginx"
    port = "80"
    connect = true
  }
}

variable "consul_tags" {
  type = list(string)
}

variable "consul_meta" {
  type = map(string)
}

variable "consul_checks_disabled" {
  type = bool
}


variable "consul_resources" {
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu = 50
    memory = 50
  }
}

variable "consul_upstreams" {
  type = list(object({
    name       = string
    local_port = number
  }))
}

variable "consul_exposes" {
  type = list(object({
    path       = string
    local_port = number
    port_label = string
  }))
}

/////////////////////////////////////////////////
// TASK nginx
/////////////////////////////////////////////////

variable "nginx_image" {
  type = string
  default = "nginx:alpine"
}

variable "nginx_resources" {
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu        = 100
    cpu_strict = false
    memory     = 50
    memory_max = 100
  }
}
