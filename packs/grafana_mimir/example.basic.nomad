
//////////////////////////////////
// Example Deployment
// > nomad-pack plan --name mimir -var-file=packs/grafana_mimir/vars.nomad packs/grafana_mimir/
//////////////////////////////////

job_name = "grafana-mimir-demo"

grafana_enabled   = true
fluentbit_enabled = true

mimir_groups = [{
  name      = "mimir-basic"
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
# Single-node w/filesystem storage
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
    backend: filesystem

blocks_storage:
  backend: filesystem
  filesystem:
    dir: /tmp/mimir/data/tsdb
  bucket_store:
    sync_dir: /tmp/mimir/tsdb-sync
  tsdb:
    dir: /tmp/mimir/tsdb

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
