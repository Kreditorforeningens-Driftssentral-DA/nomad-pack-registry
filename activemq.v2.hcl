# variable "activemq_env"
#   description: Environment variables in the task.
#   type: map(string)
#
# activemq_env=«unknown value type»


# variable "activemq_files"
#   description: Render files to '/local', and optionally mount inside container.
#   type: list(object({content = string, filename = string, mountpath = string}))
#   default: []
#
# activemq_files=[]


# variable "activemq_image"
#   type: string
#   default: "ghcr.io/kreditorforeningens-driftssentral-da/container-image-activemq:5.17.1"
#
# activemq_image="ghcr.io/kreditorforeningens-driftssentral-da/container-image-activemq:5.17.1"


# variable "activemq_resources"
#   description: N/A
#   type: object({cpu = number, cpu_strict = bool, memory = number, memory_max = number})
#   default: {"cpu" = 100, "cpu_strict" = false, "memory" = 512, "memory_max" = 1024}
#
# activemq_resources={"cpu" = 100, "cpu_strict" = false, "memory" = 512, "memory_max" = 1024}


# variable "constraints"
#   description: Constraints for placing the workloads
#   type: list(object({attribute = string, operator = string, value = string}))
#   default: []
#
# constraints=[]


# variable "datacenters"
#   description: A list of datacenters in the region which are eligible for task
#   placement
#   type: list(string)
#   default: ["*"]
#
# datacenters=["*"]


# variable "fluentbit_config"
#   type: object({content = string, filename = string, mountpath = string})
#   default: {"content" = "service:\n  daemon: off\n  http_server: off\n  flush: 5\n  log_level: error\n\npipeline:\n  inputs:\n  - name: prometheus_scrape\n    tag: activemq.prometheus\n    host: localhost\n    port: 9273\n    metrics_path: /metrics\n    scrape_interval: 10s\n      \n  outputs:\n  - name: stdout\n    match: '*.prometheus'\n", "filename" = "fluentbit.conf", "mountpath" = "/etc/fluentbit"}
#
# fluentbit_config={"content" = "service:\n  daemon: off\n  http_server: off\n  flush: 5\n  log_level: error\n\npipeline:\n  inputs:\n  - name: prometheus_scrape\n    tag: activemq.prometheus\n    host: localhost\n    port: 9273\n    metrics_path: /metrics\n    scrape_interval: 10s\n      \n  outputs:\n  - name: stdout\n    match: '*.prometheus'\n", "filename" = "fluentbit.conf", "mountpath" = "/etc/fluentbit"}


# variable "fluentbit_enabled"
#   type: bool
#   default: false
#
# fluentbit_enabled=false


# variable "fluentbit_env"
#   description: Environment variables in the task.
#   type: map(string)
#
# fluentbit_env=«unknown value type»


# variable "fluentbit_image"
#   type: string
#   default: "fluent/fluentbit:latest"
#
# fluentbit_image="fluent/fluentbit:latest"


# variable "fluentbit_resources"
#   type: object({memory = number, memory_max = number, cpu = number, cpu_strict = bool})
#   default: {"cpu" = 50, "cpu_strict" = false, "memory" = 32, "memory_max" = 64}
#
# fluentbit_resources={"cpu" = 50, "cpu_strict" = false, "memory" = 32, "memory_max" = 64}


# variable "job_name"
#   description: The name to use as the job name which overrides using the pack name
#   type: string
#
# job_name=«unknown value type»


# variable "namespace"
#   description: Override default namespace
#   type: string
#
# namespace=«unknown value type»


# variable "network_mode"
#   description: N/A
#   type: string
#   default: "bridge"
#
# network_mode="bridge"


# variable "ports"
#   description: Ports to expose on host. Set `static = 0` to use a random exposed
#   port in the Nomad range
#   type: list(object({label = string, to = number, static = number}))
#   default: [{"label" = "auto", "static" = 0, "to" = 61616}, {"label" = "webui", "static" = 0, "to" = 8161}]
#
# ports=[{"label" = "auto", "static" = 0, "to" = 61616}, {"label" = "webui", "static" = 0, "to" = 8161}]


# variable "region"
#   description: The region where jobs will be deployed
#   type: string
#
# region=«unknown value type»


# variable "services"
#   description: List of services to register with Consul
#   type: list(object({connect_resources = object({cpu = number, memory = number}), name = string, port_label = string, provider = string, tags = list(string), checks = list(object({interval = string, timeout = string, name = string, type = string, path = string, port = number})), connect_upstreams = list(object({name = string, port = number}))}))
#   default: [{"checks" = [], "connect_resources" = {"cpu" = 50, "memory" = 64}, "connect_upstreams" = [], "name" = "activemq-auto", "port_label" = "auto", "provider" = "consul", "tags" = ["traefik.enable=false"]}]
#
# services=[{"checks" = [], "connect_resources" = {"cpu" = 50, "memory" = 64}, "connect_upstreams" = [], "name" = "activemq-auto", "port_label" = "auto", "provider" = "consul", "tags" = ["traefik.enable=false"]}]


# variable "telegraf_config"
#   description: 
#   type: object({content = string, filename = string, mountpath = string})
#   default: {"content" = "[[outputs.prometheus_client]]\n  listen = \":9273\"\n    \n[[inputs.activemq]]\n  url = \"http://localhost:8161\"\n  username = \"${ACTIVEMQ_USERNAME}\"\n  password = \"${ACTIVEMQ_PASSWORD}\"\n  webadmin = \"${ACTIVEMQ_WEBADMIN}\"\n", "filename" = "telegraf.conf", "mountpath" = "/etc/telegraf"}
#
# telegraf_config={"content" = "[[outputs.prometheus_client]]\n  listen = \":9273\"\n    \n[[inputs.activemq]]\n  url = \"http://localhost:8161\"\n  username = \"${ACTIVEMQ_USERNAME}\"\n  password = \"${ACTIVEMQ_PASSWORD}\"\n  webadmin = \"${ACTIVEMQ_WEBADMIN}\"\n", "filename" = "telegraf.conf", "mountpath" = "/etc/telegraf"}


# variable "telegraf_enabled"
#   type: bool
#   default: false
#
# telegraf_enabled=false


# variable "telegraf_env"
#   description: Environment variables in the task.
#   type: map(string)
#   default: {"ACTIVEMQ_PASSWORD" = "admin", "ACTIVEMQ_USERNAME" = "admin", "ACTIVEMQ_WEBADMIN" = "admin"}
#
# telegraf_env={"ACTIVEMQ_PASSWORD" = "admin", "ACTIVEMQ_USERNAME" = "admin", "ACTIVEMQ_WEBADMIN" = "admin"}


# variable "telegraf_image"
#   type: string
#   default: "telegraf:latest"
#
# telegraf_image="telegraf:latest"


# variable "telegraf_resources"
#   type: object({memory_max = number, cpu = number, cpu_strict = bool, memory = number})
#   default: {"cpu" = 50, "cpu_strict" = false, "memory" = 32, "memory_max" = 128}
#
# telegraf_resources={"cpu" = 50, "cpu_strict" = false, "memory" = 32, "memory_max" = 128}


