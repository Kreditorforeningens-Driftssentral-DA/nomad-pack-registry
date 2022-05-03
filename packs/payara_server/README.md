# PAYARA_SERVER

## Pack requirements
* docker-driver (consul-connect)
* cni-drivers (bridged networking)

## Features
* Download maven-artifacts using ansible (maven_downloader community module) as a pre-start job (optional)
* Fluent-bit sidecar for centralized logging
* Add any number of custom files. Mount in container if required.

## Example use

```hcl
job_name = "demo-payara"

exposed_ports = [{
  name   = "http"
  target = 8080
  static = -1
},{
  name   = "debug"
  target = 9009
  static = -1
}]

ephemeral_disk = {
  migrate = true
  sticky  = true
  size    = 5000
}

resources = {
  cpu        = 500
  memory     = 512
  memory_max = 2048
}

environment_variables = {
  TZ                     = "Europe/Oslo"
  LC_ALL                 = "nb_NO.ISO-8859-1"
  PAYARA_ARGS            = "'--debug'"
  SCRIPT_DIR             = "/local/scripts"
  PATH_PREBOOT_COMMANDS  = "/local/pre-boot-commands.asadmin"
  PATH_POSTBOOT_COMMANDS = "/local/post-boot-commands.asadmin"
  ASADMIN_DEPLOY_DIR     = "/alloc/maven"
  JAVA_TOOL_OPTIONS      = "-XX:MaxRAMPercentage=80.0 -XX:InitialRAMPercentage=25.0 -XX:+ExitOnOutOfMemoryError"
}

```
