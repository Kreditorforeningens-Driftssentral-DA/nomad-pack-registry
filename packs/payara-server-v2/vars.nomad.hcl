// Example file; defines all variables
/////////////////////////////////////////////////
// SCHEDULING
/////////////////////////////////////////////////

job_name    = "demo-payara-server-v2"
namespace   = "default"

ports = [{
  label = "http"
  to     = 8080
  static = 8080
}]

#dns_servers = ["9.9.9.9", "208.67.222.222", "1.1.1.1"]

/////////////////////////////////////////////////
// TASK payara
/////////////////////////////////////////////////

payara_image = "docker.io/kdsda/payara:5.2022.2-jdk11-main"

payara_resources = {
  cpu        = 1000
  cpu_strict = true
  memory     = 512
  memory_max = 1024
}

ephemeral_disk = {
  sticky  = false
  migrate = false
  size    = 300
}

payara_env = {
  environment = "development"
}

fluentbit_enabled = false
fluentbit_env = {
  environment = "development"
}