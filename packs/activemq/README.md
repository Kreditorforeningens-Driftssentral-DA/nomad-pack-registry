# ACTIVEMQ

## Features

* Optional tasks: postgres (w/init-waiter), adminer

## Example config

```hcl
// NOMAD JOB settings

job_name = "demo-amq"

task_enabled_postgres = true
task_enabled_adminer = true

meta = {
  "deployment-id" = "2022-05-03.1"
}

resources = {
  cpu = 100
  memory = 256
  memory_max = 384
}

ephemeral_disk = {
  sticky  = true
  migrate = true
  size    = 500
}

exposed_ports = [{
  name = "webui"
  target = 8161
  static = -1
},{
  name = "adminer"
  target = 8080
  static = -1
}]

// CONSUL service settings

consul_services = [{
  name = "amq-webui"
  port = "8161"
  tags = []
  sidecar_cpu = 100
  sidecar_memory = 64
  upstreams = []
},{
  name = "amq-openwire"
  port = "61616"
  tags = []
  sidecar_cpu = 100
  sidecar_memory = 64
  upstreams = []
}]

// ACTIVEMQ task settings

environment = {
  ACTIVEMQ_DATA = "/alloc/data"
}

files = [{
  name = "/local/activemq.xml"
  content = <<HEREDOC
#..add XML-config here..
}

mounts = [{
  source = "local/activemq.xml"
  target = "/opt/activemq/conf/activemq.xml"
}]

```

