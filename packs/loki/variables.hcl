//////////////////////////////////
// SCHEDULING
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
// GROUP loki
//////////////////////////////////

variable "scale" {
  type = number
  default = 1
}

variable "ephemeral_disk" {
  type = map(object({
    size    = number
    migrate = bool
    sticky  = bool
  }))
}

variable "ports" {
  type = list(object({
    name   = string
    to     = number
    static = number
  }))
  default = [{
    name = "http"
    to = 3100
    static = -1
  }]
}

//////////////////////////////////
// CONSUL service (loki)
//////////////////////////////////

variable "consul_service" {
  type = object({
    name = string
    port = string
  })
  default = {
    name = "http-loki"
    port = 3100
  }
}

variable "consul_service_tags" {
  type = list(string)
  default = []
}

variable "consul_service_meta" {
  type = map(string)
  default = {}
}

variable "consul_sidecar_resources" {
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 100
    memory = 64
  }
}

variable "consul_checks" {
  type = list(object({
    name   = string
    path   = string
  }))
  default = [{
    name   = "ready"
    path   = "/ready"
  }]
}

variable "consul_upstreams" {
  type = list(object({
    name      = string
    bind_port = number
  }))
}

variable "consul_exposes" {
  type = list(object({
    name = string // Name of the port (will be created)
    port = number // target task-port
    path = string // path to expose
  }))
  default = []
}

//////////////////////////////////
// TASK loki
//////////////////////////////////

variable "loki_image" {
  description = "The container image used by the task."
  type = string
  default = "grafana/loki:latest"
}

variable "loki_args" {
  type = list(string)
  default = [
    "-config.file=/loki.yaml",
    "-config.expand-env=true",
    "-log-config-reverse-order",
  ]
}

variable "loki_config" {
  type = string
  default = <<-HEREDOC
  ---
  auth_enabled: false
  server:
    http_listen_port: 3100
  memberlist:
    abort_if_cluster_join_fails: false
    bind_port: 7946
    join_members: ["loki:7946"]
    max_join_retries: 10
    min_join_backoff: 3s
    max_join_backoff: 1m
  distributor:
    ring:
      kvstore:
        store: memberlist
  ingester:
    chunk_encoding: gzip
    chunk_target_size: 1572864
    chunk_idle_period: 30m
    max_chunk_age: 1h
    chunk_retain_period: 30s
    max_transfer_retries: 0
    lifecycler:
      address: 127.0.0.1
      ring:
        kvstore:
          store: memberlist
        replication_factor: 1
      final_sleep: 0s
  schema_config:
    configs:
    - from: "1981-05-11"
      store: boltdb-shipper
      object_store: aws
      schema: v11
      index:
        prefix: index_
        period: 24h
  storage_config:
    boltdb_shipper:
      active_index_directory: /local/boltdb-shipper-active
      cache_location: /local/boltdb-shipper-cache
      cache_ttl: 8h
      shared_store: s3
    aws:
      endpoint: http://localhost.:9000
      bucketnames: loki
      access_key_id: loki
      secret_access_key: lokiadmin
      s3forcepathstyle: true
      insecure: true
  limits_config:
    reject_old_samples: false
    unordered_writes: true
    max_line_size_truncate: true
    max_entries_limit_per_query: 5000
    max_query_lookback: 48h
    retention_period: 48h
  compactor:
    compaction_interval: 5m
    retention_enabled: true
    retention_delete_delay: 30m
    working_directory: /local/boltdb-shipper-compactor
    shared_store: s3
  HEREDOC
}

variable "loki_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 96
    memory_max = -1
  }
}

variable "loki_custom_files" {
  type = list(object({
    destination = string
    data        = string
  }))
}

variable "loki_custom_mounts" {
  type = list(object({
    source = string
    target = string
  }))
}

//////////////////////////////////
// TASK minio
//////////////////////////////////

variable "minio_enabled" {
  type = bool
  default = false
}

variable "minio_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu        = number
    memory     = number
    memory_max = number
  })
  default = {
    cpu = 100
    memory = 96
    memory_max = -1
  }
}

variable "minio_image" {
  description = "The container image used by the task."
  type = string
  default = "quay.io/minio/minio:latest"
}

variable "minio_config_env" {
  type = map(string)
  default = {
    minio_root_user = "loki"
    minio_root_password = "lokiadmin"
    minio_prometheus_auth_type = "public"
  }
}
