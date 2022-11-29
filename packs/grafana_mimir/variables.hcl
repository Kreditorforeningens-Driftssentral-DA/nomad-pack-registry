//////////////////////////////////
// Nomad | Scheduling
//////////////////////////////////

variable "job_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

variable "datacenters" {
  type = list(string)
  default = ["dc1"]
}

variable "constraints" {
  type = map(object({
    attribute = string
    operator  = string
    value     = string
  }))
}

//////////////////////////////////
// Group | Mimir 
//////////////////////////////////

variable "mimir_init_script" {
  description = "Pre-start task. Runs before Mimir task(s) startup."
  type        = string
  
  default = <<-HEREDOC
  #!/bin/env ash
  printf "Sleeping.\n"
  sleep 10
  HEREDOC  
}

variable "mimir_groups" {
  description = <<-HEREDOC
  Info:
    name      = Group name
    instances = Group instances
    reader    = Group accepts incoming reads (query-frontend)
    writer    = Group accepts incoming writes (distributor)
    args      = Arguments to pass the mimir binary
  HEREDOC
  
  type = list(object({
    name      = string
    instances = number
    reader    = bool
    writer    = bool
    meta      = map(string)
    args      = list(string)
  }))

  default = [{
    name       = "grafana-mimir"
    instances  = 1
    reader     = true
    writer     = true
    
    meta = {
      MimirType = "Basic"
    }

    args = [
      "-target=distributor,ingester,querier,store-gateway,compactor",
      "-config.file=/etc/mimir.yaml",
      "-config.expand-env=true",
    ]
  }]
}

variable "mimir_service_prefix" {
  type    = string
  default = "mimir-"
}

variable "mimir_service_http" {
  description = "Mimir HTTP endpoint."
  type = object({
    port           = number
    postfix        = string
    tags           = list(string)
    meta           = map(string)
    sidecar_cpu    = number
    sidecar_memory = number
    exposed        = bool
  })

  default = {
    port           = 8080
    postfix        = "http"
    tags           = []
    meta           = {}
    sidecar_cpu    = 50
    sidecar_memory = 85
    exposed        = true
  }
}

variable "mimir_service_grpc" {
  description = "Mimir gRPC endpoint."
  
  type = object({
    port           = number
    postfix        = string
    tags           = list(string)
    meta           = map(string)
    sidecar_cpu    = number
    sidecar_memory = number
  })

  default = {
    port           = 9095
    postfix        = "grpc"
    tags           = []
    meta           = {}
    sidecar_cpu    = 50
    sidecar_memory = 85
  }
}

variable "mimir_service_memberlist" {
  description = "Mimir Memberlist endpoint."
  type = object({
    port           = number
    postfix        = string
    tags           = list(string)
    meta           = map(string)
    sidecar_cpu    = number
    sidecar_memory = number
  })

  default = {
    port           = 7946
    postfix        = "memberlist"
    tags           = []
    meta           = {}
    sidecar_cpu    = 50
    sidecar_memory = 85
  }
}

variable "mimir_upstreams" {
  type = list(object({
    name = string
    local_port = number
  }))

  default = []
}

variable "mimir_ephemeral_disk" {
  type = map(object({
    size    = number
    migrate = bool
    sticky  = bool
  }))
}

variable "mimir_image" {
  description = "The container image used by the task."
  type        = string
  default     = "grafana/mimir:latest"
}

variable "mimir_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  
  default = {
    cpu        = 100
    memory     = 125
    memory_max = 250
  }
}

variable "mimir_config" {
  description = "Shared Mimir config (use CLI to override)."
  type = string
  
  default = <<-HEREDOC
  # Minimal (single-node)
  target: distributor,ingester,querier,store-gateway,compactor
  multitenancy_enabled: false
  server:
    log_level: error
  api:
    prometheus_http_prefix: /prometheus
    alertmanager_http_prefix: /alertmanager
  limits:
    compactor_blocks_retention_period: 30d
    out_of_order_time_window: 15m
  memberlist:
    cluster_label: nomad
    join_members: []
  common:
    storage:
      backend: filesystem
  blocks_storage:
    tsdb:
      dir: /tmp/mimir/ingester/
    bucket_store:
      sync_dir: /tmp/mimir/sync
  distributor:
    ring:
      kvstore:
        store: memberlist
  ingester_client:
    grpc_client_config:
      tls_enabled: false
  ingester:
    ring:
      replication_factor: 1
      observe_period: 5s
      kvstore:
        store: memberlist
  querier:
    store_gateway_client:
      tls_enabled: false
  frontend_worker:
    grpc_client_config:
      tls_enabled: false
  frontend:
    grpc_client_config:
      tls_enabled: false
  query_scheduler:
    service_discovery_mode: ring
    ring:
      kvstore:
        store: memberlist
    grpc_client_config:
      tls_enabled: false
  store_gateway:
    sharding_ring:
      replication_factor: 1
      kvstore:
        store: memberlist
  compactor:
    data_dir: /tmp/mimir/compactor
    sharding_ring:
      kvstore:
        store: memberlist
  HEREDOC
}

variable "fluentbit_enabled" {
  description = "Collect & send Mimir metrics to http-endpoint."
  type        = bool
  default     = false
}

//////////////////////////////////
// Group | Proxy (Read/Write)
//////////////////////////////////

variable "nginx_image" {
  description = "The container image used by the task."
  type        = string
  default     = "nginx:alpine"
}

variable "nginx_service" {
  type = object({
    postfix        = string
    port           = number
    sidecar_cpu    = number
    sidecar_memory = number
  })

  default = {
    postfix        = "http-proxy"
    port           = 80
    sidecar_cpu    = 50
    sidecar_memory = 75
  }
}

variable "nginx_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })

  default = {
    cpu        = 50
    memory     = 35
    memory_max = 100
  }
}

//////////////////////////////////
// Group | Grafana (testing)
//////////////////////////////////

variable "grafana_enabled" {
  type    = bool
  default = false
}

variable "grafana_service" {
  type = object({
    name           = string
    port           = number
    sidecar_cpu    = number
    sidecar_memory = number
  })

  default = {
    name           = "mimir-grafana"
    port           = 3000
    sidecar_cpu    = 50
    sidecar_memory = 85
  }
}

variable "grafana_image" {
  type    = string
  default = "grafana/grafana:latest"
}

//////////////////////////////////
// Group | Memcached (testing)
//////////////////////////////////

variable "memcached_enabled" {
  type    = bool
  default = false
}

variable "memcached_service" {
  type = object({
    name           = string
    port           = number
    sidecar_cpu    = number
    sidecar_memory = number
  })

  default = {
    name           = "mimir-memcached"
    port           = 112211
    sidecar_cpu    = 50
    sidecar_memory = 85
  }
}

variable "memcached_image" {
  type    = string
  default = "memcached/latest"
}

//////////////////////////////////
// Group | MinIO (testing)
//////////////////////////////////

variable "minio_enabled" {
  type    = bool
  default = false
}

variable "minio_image" {
  description = "The container image used by the task."
  type        = string
  default     = "quay.io/minio/minio:latest"
}

variable "minio_service" {
  type = object({
    name           = string
    port           = number
    sidecar_cpu    = number
    sidecar_memory = number
  })

  default = {
    name           = "mimir-minio"
    port           = 9000
    sidecar_cpu    = 50
    sidecar_memory = 85
  }
}

/*variable "task_minio_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu        = 100
    memory     = 150
    memory_max = 300
  }
}*/

//////////////////////////////////
// Group | Memcached (demo)
//////////////////////////////////

/*variable "memcached_enabled" {
  type    = bool
  default = false
}

variable "memcached_image" {
  description = "The container image used by the task."
  type        = string
  default     = "quay.io/minio/minio:latest"
}

variable "memcached_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    cpu_strict = bool
    memory     = number
    memory_max = number
  })
  default = {
    cpu        = 50
    cpu_strict = false
    memory     = 75
    memory_max = 125
  }
}*/
