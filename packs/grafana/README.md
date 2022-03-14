# GRAFANA PACK

Creates a Grafana job. Features:

  * Optional consul service registration
  * Optional consul upstream connections
  * Add as many config-files as required & env. variables.

## Example input
```hcl
#nomad-pack run -var-file example.hcl

#example.hcl
job_name = "grafana"

files = [{
  name = "grafana.ini"
  safe = false
  content = <<-EOH
  instance_name = grafana
  [security]
    admin_user = grafana
    admin_password = grafana123
    disable_initial_admin_creation = false
  [users]
    default_theme = dark
  [date_formats]
    default_timezone = Europe/Oslo
  EOH
},{
  name = "provisioning/datasources/loki.yaml"
  safe = false
  content = <<-EOH
  ---
  apiVersion: 1
  datasources:
  - name: KIS Logs
    type: loki
    access: proxy
    url: http://{{ env "NOMAD_UPSTREAM_ADDR_loki1" }}
    jsonData:
      maxLines: 500
  - name: KOS Logs
    type: loki
    access: proxy
    url: http://{{ env "NOMAD_UPSTREAM_ADDR_loki2" }}
    jsonData:
      maxLines: 500
  ...
  EOH
}]

// Consul

consul_services = [{
  name = "http-grafana"
  port = 3000
  tags = ["traefik.enable=false"]
  cpu = 100
  memory = 64
  upstream_first_port = 5000
  upstreams = ["loki1","loki2"]
}]

// Logging

fluentbit_args = ["-c", "/local/fluent-bit.conf"]

fluentbit_files = [{
  name = "fluent-bit.conf"
  b64encode = false
  content = <<-EOH
  [SERVICE]
    Flush        5
    Daemon       off
    Log_Level    debug
    #Parsers_File {{ env "NOMAD_TASK_DIR" }}/parsers/custom.conf
    #Parsers_File /fluent-bit/etc/parsers.conf
  @INCLUDE {{ env "NOMAD_TASK_DIR" }}/inputs/*.conf
  @INCLUDE {{ env "NOMAD_TASK_DIR" }}/outputs/*.conf
  EOH
},{  
  name = "inputs/grafana.conf"
  b64encode = false
  content = <<-EOH
  [INPUT]
    Name             tail
    Tag              tail.grafana.stdout
    Path             {{ env "NOMAD_ALLOC_DIR" }}/logs/grafana.stdout.*
    Path_Key         Filename
    Inotify_Watcher  True
    Read_from_Head   True
    Skip_Long_Lines  On
    Skip_Empty_Lines Off
    DB               {{ env "NOMAD_TASK_DIR" }}/grafana.db
    DB.locking       true
  EOH
},{  
  name = "outputs/grafana.conf"
  b64encode = false
  content = <<-EOH
  [OUTPUT]
    Name  stdout
    Match *
  EOH
},{
  name = "parsers/custom.conf"
  b64encode = false
  content = <<-EOH
  # Add your own parser(s)
  EOH
}]
```