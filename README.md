# NOMAD-PACK-REGISTRY (PUBLIC)

## LIST OF PACKS

| PACK-ID          | APPLICATION                                          |
| :--              | :--                                                  |
| activemq         | [ActiveMQ](packs/activemq/README.md)                 |
| activemq-v2      | [ActiveMQ](packs/activemq-v2/README.md)              |
| alert2teams      | [Alert Forwarding](packs/alert2teams/README.md)      |
| alertmanager     | [Alertmanager](packs/alertmanager/README.md)         |
| bitbucker_runner | [Bitbucket-Runner](packs/bitbucket_runner/README.md) |
| example          | [Example](packs/example/README.md)                   |
| fluentbit        | [Fluentbit](packs/fluentbit/README.md)               |
| grafana          | [Grafana](packs/grafana/README.md)                   |
| grafana loki     | [Grafana Loki](packs/loki/README.md)                 |
| grafana mimir    | [Grafana Mimir](packs/grafana_mimir/README.md)       |
| payara_server    | [Payara Server](packs/payara_server/README.md)       |
| prometheus       | [Prometheus](packs/prometheus/README.md)             |
| traefik          | [Traefik](packs/traefik/README.md)                   |

## USAGE

```bash
# Add pack registry (public)
nomad-pack registry add -h
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry
nomad-pack registry list

# Add specific version
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --ref example-v0.0.1 --target example

# Render pack to console
nomad-pack render example --registry=kred-public

# Run pack w/registry version
source nomad.env
nomad-pack plan   example --registry=kred-public
nomad-pack run    example --registry=kred-public

# Generate variables-file
nomad-pack generate var-file packs/example -o vars.hcl

# Use packs locally (e.g. cloned from git)
source nomad.env
nomad-pack render  -name demo -var job_name=demo packs/example
nomad-pack plan    -name demo -var job_name=demo packs/example
nomad-pack run     -name demo -var job_name=demo packs/example
nomad-pack destroy -name demo -var job_name=demo packs/example
```

## RESOURCES

  * [Public nomad-pack registry ](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs)
  * [Nomad-pack template-functions](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs#template-functions)
  * [Sprig template-functions](http://masterminds.github.io/sprig/)
  * [Go-template syntax](https://learn.hashicorp.com/tutorials/nomad/go-template-syntax)
  * [Go Text/template-functions](https://pkg.go.dev/text/template)
