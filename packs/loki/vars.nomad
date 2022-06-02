//////////////////////////////////
// SCHEDULING
//////////////////////////////////

job_name = "demo-loki"
namespace = "default"

ephemeral_disk = {
  size    = 500
  migrate = true
  sticky  = true
}

ports = []

connect_exposes = [{
  port_label = "metrics"
  local_port = 3100
  path = "/metrics"
}]

//////////////////////////////////
// CONSUL services (loki)
//////////////////////////////////

consul_services = [{
  port = 3100
  name = "demo-loki"
  tags = []
  meta = {
    prometheus_metrics_port = "$${NOMAD_PORT_metrics}"
  }
  sidecar_cpu = 50
  sidecar_memory = 50
}]

//////////////////////////////////
// TASK loki
//////////////////////////////////

// Remove default config/mount if using custom file
loki_config = ""

// Set custom loki startup-arguments
loki_args = [
  "-config.file=/local/loki_minio.yaml",
  "-config.expand-env=true",
  "-log-config-reverse-order",
]

// Add multipe config-files
loki_files = [{
  destination = "/local/loki_local.yaml"
  data = <<HEREDOC
auth_enabled: false
server:
  http_listen_port: 3100
memberlist:
  abort_if_cluster_join_fails: false
  bind_port: 7946
  join_members: ["127.0.0.1:7946"]
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
  - from: 1981-05-11
    store: boltdb
    object_store: filesystem
    schema: v11
    index:
      prefix: index_
      period: 24h
storage_config:
  boltdb:
    directory: /local/loki/index
  filesystem:
    directory: /local/loki/chunks
limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 48h
HEREDOC
},{
  destination = "/local/loki_minio.yaml"
  data = <<HEREDOC
auth_enabled: false
server:
  http_listen_port: 3100
memberlist:
  abort_if_cluster_join_fails: false
  bind_port: 7946
  join_members: ["127.0.0.1:7946"]
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
}]

//////////////////////////////////
// TASK minio
//////////////////////////////////

minio_enabled = true

minio_env = {
  minio_root_user = "loki"
  minio_root_password = "lokiadmin"
  minio_prometheus_auth_type = "public"
}