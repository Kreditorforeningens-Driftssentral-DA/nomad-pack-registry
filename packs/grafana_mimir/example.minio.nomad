
//////////////////////////////////
// Example Deployment
// > nomad-pack plan --name mimir -var-file=packs/grafana_mimir/vars.nomad packs/grafana_mimir/
//////////////////////////////////

job_name = "grafana-mimir-demo"

fluentbit_enabled = true
grafana_enabled   = true
minio_enabled     = true // default service: "mimir-minio"

mimir_upstreams = [{
  name       = "mimir-minio"
  local_port = 9000
}]

#curl -I -X GET --retry 10 --retry-connrefused --retry-delay 3 $MINIO_URL
mimir_init_script = <<HEREDOC
#!/bin/env ash
export MINIO_URL=http://127.0.0.1:9000/minio/health/live
until false
do
  wget --spider -q $MINIO_URL
  if [ $? -eq 0 ]; then
    break
  fi
  printf "Retrying in 3 ..\n"
  sleep 3
done
HEREDOC

mimir_groups = [{
  name      = "mimir-minio"
  instances = 1
  reader    = true
  writer    = true
  meta = {}
  args = [
    "-target=distributor,ingester,querier,store-gateway,compactor",
    "-config.file=/etc/mimir.yaml",
    "-config.expand-env=true",
  ]
}]

mimir_config = <<HEREDOC
# Single-node w/MinIO
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
  cluster_label: x-nomad
  node_name: mimir-1
  advertise_addr: 127.0.0.1
  join_members: ["localhost:7947"]

common:
  storage:
    backend: s3
    s3:
      endpoint: 127.0.0.1:9000
      access_key_id: MinIO
      secret_access_key: Mimir@Min10
      insecure: true
      bucket_name: mimir

blocks_storage:
  storage_prefix: blocks
  tsdb:
    dir: /tmp/mimir/ingester

distributor:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist

ingester_client:
  grpc_client_config:
    tls_enabled: false

ingester:
  ring:
    replication_factor: 1
    instance_addr: 127.0.0.1
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
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist
  grpc_client_config:
    tls_enabled: false

store_gateway:
  sharding_ring:
    replication_factor: 1
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist

compactor:
  data_dir: /tmp/mimir/compactor
  sharding_ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist
HEREDOC
