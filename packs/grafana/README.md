# GRAFANA PACK

Creates a Grafana job. Features:

  * Optional consul service registration
  * Optional consul upstream connections
  * Add custom files & env. variables

## Example input
```hcl
#nomad-pack run packs/grafana -var-file example.hcl

#example.hcl
job_name = "demo-grafana"

environment = {
  GF_PATHS_CONFIG       = "/local/grafana.ini"
  GF_PATHS_PROVISIONING = "/local/provisioning"
  GF_PATHS_DATA         = "/local/grafana"
  GF_INSTALL_PLUGINS    = "grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel"
}

files = [{
  target = "/local/grafana.ini"
  content = <<-EOH
  instance_name = grafana
  [security]
    admin_user = batman
    admin_password = manbat
    disable_initial_admin_creation = false
  [users]
    default_theme = dark
  [date_formats]
    default_timezone = Europe/Oslo
  EOH
},{
  name = "/local/provisioning/datasources/loki.yaml"
  safe = false
  content = <<-EOH
  ---
  apiVersion: 1
  datasources:
  - name: LokiLogs1
    type: loki
    access: proxy
    url: http://{{ env "NOMAD_UPSTREAM_ADDR_loki1" }}
    jsonData:
      maxLines: 1500
  - name: LokiLogs1
    type: loki
    access: proxy
    url: http://{{ env "NOMAD_UPSTREAM_ADDR_loki2" }}
    jsonData:
      maxLines: 1500
  ...
  EOH
}]

consul_service = {
  port = 3000
  name = "http-grafana"
  tags = ["traefik.enable=false"]
  sidecar_cpu = 100
  sidecar_memory = 64
  upstreams = [{
    service = "loki1"
    port    = 1000
  },{
    service = "loki2"
    port    = 1001
  }]
}

```