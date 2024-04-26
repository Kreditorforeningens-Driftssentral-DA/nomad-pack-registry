////////////////////////
// Allocation
////////////////////////

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["*"]
}

variable "namespace" {
  description = "Override default namespace"
  type        = string
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
}

variable "constraints" {
  description = "Constraints for placing the workloads"
  
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  
  default = []
}

variable "network_mode" {
  description = "N/A"
  type        = string
  default     = "bridge"
}

variable "ports" {
  description = "Ports to expose on host. Set `static = 0` to use a random exposed port in the Nomad range"
  
  type = list(object({
    label  = string
    to     = number
    static = number
  }))

  default  = [{
    label  = "http"
    to     = 8080
    static = 8080
  }, {
    label  = "admin"
    to     = 4848
    static = 4848
  }]
}

variable "ephemeral_disk" {
  description = "Persist '/alloc/data' content between allocations."
  
  type = object({
    sticky  = bool   // Try to place new alloc on same host; migrate /local & /alloc/data
    migrate = bool   // Try to migrate data, even if host changes. Implies 'sticy=true'
    size    = number // Size to reserve on host. Not enforced, but used for scheduling
  })
}

////////////////////////
// Services
////////////////////////

variable "services" {
  description = "List of services to register with Nomad/Consul provider"

  type = list(object({
    provider   = string
    name       = string
    port_label = string
    tags       = list(string)
    
    checks = list(object({
      name         = string
      type         = string
      path         = string
      port         = number
      interval     = string
      timeout      = string
    }))

    connect_upstreams = list(object({
      name = string
      port = number
    }))
    
    connect_resources = object({
      cpu    = number
      memory = number
    })
  }))
  
  default = [{
    provider          = "consul"
    name              = "payara-server-http"
    port_label        = "http"
    tags              = ["traefik.enable=false"]
    checks            = []
    connect_upstreams = []
    connect_resources = {
      cpu    = 50
      memory = 64
    }
  }]
}

////////////////////////
// Payara Server Task (Leader)
////////////////////////

variable "payara_image" {
  description = "N/A"
  type        = string
  default     = "ghcr.io/kred-no/packer-builds/payara-server:6.2024.4"
}

variable "payara_resources" {
  description = "N/A"

  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })

  default = {
    cpu_strict = false
    cpu        = 250
    memory     = 2 * 1024
    memory_max = 4 * 1024
  }
}

variable "payara_env" {
  description = "Environment variables in the task."
  type        = map(string)
}

variable "payara_files" {
  description = "Render files to '/local', and optionally mount inside container."
  
  type = list(object({
    filename  = string
    mountpath = string
    content   = string
  }))
  
  default = [{
    filename  = "prestart.sh"
    mountpath = "/opt/payara/scripts/init.d"
    content = <<-HEREDOC
    #!/usr/bin/env bash
    printf "You can add custom scripts, etc, which will execute before server startup\n"
    HEREDOC
  }, {
    filename  = "preboot-commands.asadmin"
    mountpath = ""
    content = <<-HEREDOC
    # Preeboot Commands
    # Add asadmin-commands here
    HEREDOC
  }, {
    filename  = "postboot-commands.asadmin"
    mountpath = ""
    content = <<-HEREDOC
    # Postboot Commands
    # Add asadmin-commands here
    HEREDOC
  }]
}

variable "payara_artifacts" {
  description = "Render artifacts to '/local'."
  
  type = list(object({
    source      = string
    destination = string
    mode        = string
    options     = map(string)
  }))
  
  default = [/*{
    source      = "https://repo1.maven.org/maven2/org/apache/activemq/activemq-rar/6.1.0/activemq-rar-6.1.0.rar"
    destination = "/local/activemq-rar.rar"
    mode        = "file"
    options = {
      "checksum" = "md5:4f27d49fa85562fbdb00628a56333225"
    }
  }*/]
}

////////////////////////
// FluentBit SidecarTask
////////////////////////

variable "fluentbit_enabled" {
  description = "N/A"
  type        = bool
  default     = false
}

variable "fluentbit_image" {
  description = "N/A"
  type        = string
  default     = "fluent/fluent-bit:3.0"
}

variable "fluentbit_resources" {
  description = "N/A"
  
  type = object({
    cpu_strict = bool
    cpu        = number
    memory     = number
    memory_max = number
  })

  default = {
    cpu_strict = false
    cpu        = 50
    memory     = 32
    memory_max = 64
  }
}

variable "fluentbit_env" {
  description = "Environment variables in the task."
  type        = map(string)
}

variable "fluentbit_config" {
  description = <<-HEREDOC
  Fluent-Bit configuration-file.
  The Fluent-Bit startup-command targets this file (hardcoded), so don't change the name/path.
  The default input-config included here targets the local payara instance /metrics endpoint.
  This endpont can be enabled with: 'set-metrics-configuration --enabled=true --dynamic=true' from postboot-script.
  HEREDOC

  type = object({
    filename  = string
    mountpath = string
    content   = string
  })

  default = {
    filename  = "fluentbit.yml"
    mountpath = "/etc/fluentbit"
    content = <<-HEREDOC
    # PLEASE validate config using '--dry-run' flag before updating
    service:
      daemon: off
      http_server: off
      flush: 5
      log_level: error

    pipeline:
      inputs:
      - name: prometheus_scrape
        tag: payara.prometheus
        host: 127.0.0.1
        port: 8080
        metrics_path: /metrics
        scrape_interval: 10s
      
      outputs:
      - name: stdout
        match: '*.prometheus'
    HEREDOC
  }
}
