// EXAMPLE vars-file

/////////////////////////////////////////////////
// SCHEDULING
/////////////////////////////////////////////////

job_name = "demo-activemq"

meta = {
  "deployment-id" = "2022-05.1"
}

ephemeral_disk = {
  migrate = true
  sticky = true
  size = 500
}

ports = [{
  name = "console"
  to = 8161
  static = -1
}]

/////////////////////////////////////////////////
// CONSUL service
/////////////////////////////////////////////////

consul_service = {
  name = "demo-activemq-console"
  port = "8161"
}

consul_tags = ["traefik.enable=false"]

consul_meta = {
  metrics_prometheus_port = "$${NOMAD_HOST_PORT_telegraf}"
  metrics_prometheus_path = "/metrics"
}

consul_exposes = [{
  port_label = "telegraf"
  local_port = 9273
  path = "/metrics"
}]

consul_services = [{
  name = "demo-activemq-openwire"
  port = "61616"
  tags = []
  meta = {}
  sidecar_cpu = 50
  sidecar_memory = 50
}]

/////////////////////////////////////////////////
// TASK telegraf
/////////////////////////////////////////////////

task_enabled_telegraf = true

telegraf_resources = {
  cpu = 50
  memory = 64
  memory_max = -1
}

telegraf_credentials = {
  activemq_username = "admin"
  activemq_password = "admin"
  activemq_webadmin = "admin"
}

telegraf_config = <<-HEREDOC
[[outputs.prometheus_client]]
  listen = ":9273"
[[inputs.activemq]]
  url = "http://localhost:8161"
  username = "$${ACTIVEMQ_USERNAME}"
  password = "$${ACTIVEMQ_PASSWORD}"
  webadmin = "$${ACTIVEMQ_WEBADMIN}"
HEREDOC

/////////////////////////////////////////////////
// TASK activemq
/////////////////////////////////////////////////

activemq_image = "ghcr.io/kreditorforeningens-driftssentral-da/container-image-activemq:5.17.1"

activemq_resources = {
  cpu = 100
  cpu_strict = false
  memory = 256
  memory_max = 512
}

activemq_custom_mounts = [{
  source = "local/info.txt"
  target = "/opt/activemq/conf/info.txt"
}]

activemq_custom_files = [{
  name = "/local/info.txt"
  data = <<EOH
This is just an example file, rendered to {{ env "NOMAD_TASK_DIR" }}/config/info.txt.
Example: NOMAD_JOB_NAME = {{ env "NOMAD_JOB_NAME" }}
EOH
}]

