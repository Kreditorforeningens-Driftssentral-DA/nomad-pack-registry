# NOMAD-PACK-REGISTRY (PUBLIC)

## Details

Packs in this repository: 
  
| PACK-ID | APPLICATION | LATEST TAG |
| :--     | :--         | :--        |
| activemq         | [ActiveMQ](packs/activemq/README.md) | (latest) |
| alert2teams      | [Alert Forwarding](packs/alert2teams/README.md) | (latest) |
| alertmanager     | [Alertmanager](packs/alertmanager/README.md) | (latest) |
| bitbucker_runner | [Bitbucket-Runner](packs/bitbucket_runner/README.md) | (latest) |
| example          | [Example](packs/example/README.md) | (latest) |
| fluentbit        | [Fluentbit](packs/fluentbit/README.md) | (latest) |
| grafana          | [Grafana](packs/grafana/README.md) | (latest) |
| grafana loki     | [Grafana Loki](packs/loki/README.md) | (latest) |
| grafana mimir    | [Grafana Mimir](packs/grafana_mimir/README.md) | (latest) |
| payara_server    | [Payara Server](packs/payara_server/README.md) | (latest) |
| prometheus       | [Prometheus](packs/prometheus/README.md) | (latest) |
| traefik          | [Traefik](packs/traefik/README.md) | (latest) |

## Usage

```bash
# Add entire pack registry (public)
nomad-pack registry add -h
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry
nomad-pack registry list
```

```bash
# Get specific version
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --ref payara_server-v0.0.4 --target payara_server
```

```bash
# Run w/registry version
source nomad.env
nomad-pack render payara_server --registry=kred-public
nomad-pack plan   payara_server --registry=kred-public
nomad-pack run    payara_server --registry=kred-public
```

```bash
# Use packs locally (e.g. cloned from git)
source nomad.env
nomad-pack render  -name demo -var job_name=demo packs/example
nomad-pack plan    -name demo -var job_name=demo packs/example
nomad-pack run     -name demo -var job_name=demo packs/example
nomad-pack destroy -name demo -var job_name=demo packs/example
```

## References for writing packs

  * [Public nomad-pack registry ](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs)
  * [Nomad-pack template-functions](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs#template-functions)
  * [Sprig template-functions](http://masterminds.github.io/sprig/)
  * [Go-template syntax](https://learn.hashicorp.com/tutorials/nomad/go-template-syntax)
  * [Go Text/template-functions](https://pkg.go.dev/text/template)
