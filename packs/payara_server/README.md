# PAYARA_SERVER

NOTE: Running v1 packs with nomad-pack v0.1.0 or newer, requires the following flag: `--parser-v1`

## Pack requirements
* docker-driver (consul-connect)
* cni-drivers (bridged networking)

## Features
* Download maven-artifacts using ansible (maven_downloader community module) as a pre-start job (optional)
* Fluent-bit sidecar for centralized logging
* Add any number of custom files. Mount in container if required.

## Example use

```bash
# Run with nomad-pack binary (from local folder)
nomad-pack render --parser-v1 -f payara_server/vars.nomad payara_server/

# Run with nomad-pack binary (from registry)
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --target=payara_server
nomad-pack render --registry kred-public --parser-v1 -f vars.nomad payara_server
```

```bash
# Run with podman/docker
# Add registry with custom Dockerfile, if not mapping folder
alias nomad-pack-x='podman run --rm -it -v ./payara_server/:/payara_server:ro,z  docker.io/hashicorp/nomad-pack:latest'
nomad-pack-x render --parser-v1 -f /payara_server/vars.nomad /payara_server/
unalias nomad-pack-x
```

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
  size    = 2000
}

resources = {
  cpu        = 500
  memory     = 768
  memory_max = 2048
}

environment_variables = {
  TZ                     = "Europe/Oslo"
  LC_ALL                 = "nb_NO.ISO-8859-1"
  PAYARA_ARGS            = "'--debug'"
  SCRIPT_DIR             = "/local/scripts"
  PATH_PREBOOT_COMMANDS  = "/local/pre-boot-commands.asadmin"
  PATH_POSTBOOT_COMMANDS = "/local/post-boot-commands.asadmin"
}

// Only required if not exposing application-port on host. NOTE: Service health-checks are "automatically" exposed 
#consul_exposes = [{
#  name = "prometheus-metrics"
#  port = 8080
#  path = "/metrics"
#}]

```
