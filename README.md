# NOMAD-PACK-REGISTRY (PUBLIC)

## Details

Packs in this repository:
  
| NAME | CURRENT TAG |
| :--  | :--         |
| [ActiveMQ](packs/activemq/README.md) | activemq-v0.0.2 |
| [Bitbucket-Runner](packs/bitbucket_runner/README.md) | (latest) |
| [Example](packs/example/README.md) | (latest) |
| [Fluentbit](packs/fluentbit/README.md) | (latest) |
| [Grafana](packs/grafana/README.md) | (latest) |
| [Grafana Loki](packs/loki/README.md) | loki-v0.0.2 |
| [Payara (server)](packs/payara_server/README.md) | payara_server-v0.0.3 |
| [Prometheus](packs/prometheus/README.md) | prometheus-v0.0.1 |

## Usage

```bash
# Use packs locally (dev)
source nomad-test.env
nomad-pack render  -name demo -var job_name=demo packs/example
nomad-pack plan    -name demo -var job_name=demo packs/example
nomad-pack run     -name demo -var job_name=demo packs/example
nomad-pack destroy -name demo -var job_name=demo packs/example

# Add (public) pack registry
nomad-pack registry add -h
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry@latest
nomad-pack registry list

# Verify
nomad-pack render bitbucket_runner --registry=kred-public --ref=latest
```

## References for writing packs

  * [Public nomad-pack registry ](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs)
  * [Nomad-pack template-functions](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs#template-functions)
  * [Sprig template-functions](http://masterminds.github.io/sprig/)
  * [Go-template syntax](https://learn.hashicorp.com/tutorials/nomad/go-template-syntax)
  * [Go Text/template-functions](https://pkg.go.dev/text/template)
