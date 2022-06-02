# PACK: GRAFANA LOKI

## Example

* https://github.com/grafana/loki/blob/main/docs/sources/configuration/examples.md

## Included tasks (docker)

  * Loki
  * Minio (optional)

## Pack variables

| Variable | Type | Default | Description |
| --:      | :--  | :-:     | :--         |
| job_name | string | unset | Name of the job |
| namespace | string | unset | Nomad namespace |
| datacenters | list(string) | ["dc1"] | Datacenters |
| region | string | undefined | |
| constraints | map(object()) | defined | |
| scale | number | 1 | Number of group-instances |
| ephemeral_disk | map(object()) | undefined | |
| ports | list(object()) | defined | |
||
| consul_services | list(object()) | undefined | |
| connect_upstreams | list(object()) | undefined | |
| connect_exposes | list(object()) | undefined | |
||
| loki_image | string | grafana/loki:latest | |
| loki_resources | object() | defined | |
| loki_args | list(string) | defined | |
| loki_config | string | defined | |
| loki_files | list(object()) | undefined | |
| loki_mounts | list(object()) | undefined | |
||
| minio_enabled | bool | false | |
| minio_image | string | quay.io/minio/minio:latest | |
| minio_resources | object() | defined | |
| minio_env | map(string) | defined | |
