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
  default = []
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
      first_port = number
      services   = list(string)
    })
  }))
  default = []
}

/////////////////////////////////////////////////
// Task runner (main)
/////////////////////////////////////////////////

variable "image" {
  description = "Container image to use for the task."
  type = object({
    name = string
    tag  = string
  })
  default = {
    name = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner"
    tag = "1"
  }
}

variable "resources" {
  description = "Define resource requirements."
  type = object({
    cpu = number
    memory = number
    memory_max = number
  })
  default = {
    cpu = 200
    memory = 384
    memory_max = 512
  }
}

variable "privileged" {
  description = "Run docker-task in privileged mode."
  type = bool
  default = false
}

variable "environment" {
  description = "Custom environment variables."
  type = map(string)
}

variable "settings" {
  description = "Bitbucket runner parameters from bitbucket site."
  type = object({
    account_uuid                  = string
    oauth_client_id               = string
    oauth_client_secret           = string
    runner_uuid                   = string
    runtime_prerequisites_enabled = string
    working_directory             = string
  })
}

variable "files" {
  description = "Create files for the job."
  type = list(object({
    name      = string
    b64encode = bool
    content   = string
  }))
}

variable "mounts" {
  description = "Mounts for the runner. Note that privileged mode is required for host bind-mounts."
  type = list(object({
    type     = string
    source   = string
    target   = string
    readonly = bool
  }))
  default = [{
    type = "bind"
    target = "/var/run/docker.sock"
    source = "/var/run/docker.sock"
    readonly = false
  },{
    type = "bind"
    target = "/tmp"
    source = "/tmp"
    readonly = false
  },{
    type = "bind"
    target = "/var/lib/docker/containers"
    source = "/var/lib/docker/containers"
    readonly = true
  }]
}
