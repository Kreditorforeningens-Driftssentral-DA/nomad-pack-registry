//////////////////////////////////
// SCHEDULING
//////////////////////////////////

job_name = "demo-loki"

//////////////////////////////////
// LOKI
//////////////////////////////////

ports = [] // Only access using consul-connect

//////////////////////////////////
// CONSUL services (loki)
//////////////////////////////////

consul_service = {
  name = "demo-loki"
  port = 3100
}

consul_service_tags = ["traefik.enable=false"]

// Expose extra endpoint for metrics (creates port)
consul_exposes = [{
  name = "prometheus-metrics"
  path = "/metrics"
  port = 3100
}]

// Add metadata for prometheus scraping
consul_service_meta = {
  metrics_prometheus_port = "$${NOMAD_HOST_PORT_prometheus_metrics}"
  metrics_prometheus_path = "/metrics"
}

//////////////////////////////////
// TASK loki
//////////////////////////////////

// Remove default config, to avoid mounting (using multiple files)
#loki_config = ""

// Set custom loki startup-arguments
loki_args = [
  "-config.file=/local/loki_local.yaml",
  "-config.expand-env=true",
  "-log-config-reverse-order",
]

// Add extra config-files
loki_custom_files = [{
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
}]
