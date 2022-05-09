//////////////////////////////////
// SCHEDULER
//////////////////////////////////

job_name = "demo-payara"

constraints = [{
  attribute = "$${attr.kernel.name}"
  value = "linux"
  operator = ""
},{
  attribute = ""
  operator = "distinct_hosts"
  value = "true"
}]

//////////////////////////////////
// GROUP payara
//////////////////////////////////

meta = {
  "deployment-id" = "2022-05.0"
}

ports = [{
  name = "http"
  to = 8080
  static = -1
}]

ephemeral_disk = {
  sticky = true
  migrate = false
  size = 300
}

//////////////////////////////////
// CONSUL payara
//////////////////////////////////

consul_service = {
  name = "demo-http-payara"
  port = "8080"
}

// Requires atleast 1 deployed application
consul_checks = [{
  name = "ready"
  port = "http"
  path = "/health"
  expose = false
}]

consul_service_tags = [
  "traefik.enable=false",
]

consul_service_meta = {
  "metrics_prometheus_port" = "$${NOMAD_HOST_PORT_http}" // If using connect, expose a port using consul_exposes
  "metrics_prometheus_path" = "/metrics"
}

consul_upstreams = []

//////////////////////////////////
// TASK payara
//////////////////////////////////

payara_image = "kdsda/payara:5.2022.2-jdk11-main"

payara_resources = {
  cpu = 100
  cpu_hard_limit = false
  memory = 384
  memory_max = 768
}

payara_artifacts = [{
  source = "https://raw.githubusercontent.com/aeimer/java-example-helloworld-war/master/dist/helloworld.war"
  destination = "/local/deploy/helloworld.war"
  mode = "file"
  options = {}
}]

payara_environment_vars = {
  TZ                     = "Europe/Oslo"
  LC_ALL                 = "nb_NO.ISO-8859-1"
  PATH_POSTBOOT_COMMANDS = "/local/post-boot-commands.asadmin"
}

// https://github.com/payara/Payara-Server-Documentation/blob/master/documentation/payara-server/health-check-service/asadmin-commands.adoc#set-healthcheck-configuration
// https://github.com/payara/Payara-Examples/tree/master/javaee
payara_custom_files = [{
  destination  = "/local/post-boot-commands.asadmin"
  data = <<-HEREDOC
  set-healthcheck-configuration --enabled=true --dynamic=true # Requires atleast 1 deployed/healthy application
  deploy /local/deploy/helloworld.war
  HEREDOC
}]

//////////////////////////////////
// TASK maven
//////////////////////////////////

task_enabled_maven = false

maven_image = "kdsda/ansible:2022.15"

maven_auth = {
  server = "https://repo1.maven.org"
  username = "123"
  password = "123"
}

maven_artifacts = []


//////////////////////////////////
// TASK fluent-bit
//////////////////////////////////

task_enabled_fluentbit = true

fluentbit_image = "fluent/fluent-bit:latest"

fluentbit_config = <<-HEREDOC
[SERVICE]
  Daemon      False
  Http_Server False
  Flush       5
  Log_Level   Info

[INPUT]
  Name             tail
  Tag              payara.tail
  Path             /alloc/logs/payara.stderr.*
  Path_Key         filename
  Read_From_Head   True
  Skip_Long_Lines  True
  Skip_Empty_Lines True
  DB               /local/payara.stderr.db
  DB.locking       True

[OUTPUT]
  Name  stdout
  Match *
HEREDOC

fluentbit_files = []
