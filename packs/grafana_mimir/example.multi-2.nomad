
//////////////////////////////////
// Example Deployment
// > nomad-pack plan --name mimir -var-file=packs/grafana_mimir/vars.nomad packs/grafana_mimir/
//////////////////////////////////

job_name = "grafana-mimir-demo"

fluentbit_enabled = true
grafana_enabled   = true
minio_enabled     = true // default service name "mimir-minio"

mimir_upstreams = [{
  name       = "mimir-minio"
  local_port = 9000
}]

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
  name      = "mimir-frontend"
  instances = 1
  reader    = true
  writer    = true
  meta = {}
  args = [
    "-target=distributor,query-frontend",
    "-config.file=/etc/mimir.yaml",
    "-config.expand-env=true",
  ]
}, {
  name      = "mimir-core"
  instances = 3
  reader    = false
  writer    = false
  meta = {}
  args = [
    "-target=query-scheduler,querier,ingester,store-gateway,compactor",
    "-config.file=/etc/mimir.yaml",
    "-config.expand-env=true",
  ]
}]

mimir_config = <<HEREDOC
# Multi-node w/MinIO
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
  node_name: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}
  advertise_addr: $${NOMAD_HOST_IP_memberlist}
  advertise_port: $${NOMAD_HOST_PORT_memberlist}
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
  remote_timeout: 5s
  ring:
    instance_id: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}
    instance_addr: $${NOMAD_HOST_IP_grpc}
    instance_port: $${NOMAD_HOST_PORT_grpc}
    kvstore:
      store: memberlist

ingester:
  ring:
    replication_factor: 2
    instance_id: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}
    instance_addr: $${NOMAD_HOST_IP_grpc}
    instance_port: $${NOMAD_HOST_PORT_grpc}
    kvstore:
      store: memberlist

frontend:
  address: $${NOMAD_HOST_IP_grpc}
  port: $${NOMAD_HOST_PORT_grpc}

frontend_worker:
  id: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}

query_scheduler:
  service_discovery_mode: ring
  ring:
    instance_id: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}
    instance_addr: $${NOMAD_HOST_IP_grpc}
    instance_port: $${NOMAD_HOST_PORT_grpc}
    kvstore:
      store: memberlist

store_gateway:
  sharding_ring:
    replication_factor: 2
    instance_id: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}
    instance_addr: $${NOMAD_HOST_IP_grpc}
    instance_port: $${NOMAD_HOST_PORT_grpc}
    kvstore:
      store: memberlist

compactor:
  data_dir: /tmp/mimir/compactor
  sharding_ring:
    instance_id: $${NOMAD_GROUP_NAME}-$${NOMAD_ALLOC_INDEX}
    instance_addr: $${NOMAD_HOST_IP_grpc}
    instance_port: $${NOMAD_HOST_PORT_grpc}
    kvstore:
      store: memberlist
HEREDOC
