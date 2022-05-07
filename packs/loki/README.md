# PACK: GRAFANA LOKI

## Example

* https://github.com/grafana/loki/blob/main/docs/sources/configuration/examples.md

## Included tasks (docker)

  * Loki
  * Minio (optional)
  * Redis (optional)

## Pack variables

| Variable | Type | Default | Description |
| :-- | :-: | :-: | :-- |
| job_name | string | unset | Name of the job |
| datacenters | list(string) | ["dc1"] | Datacenters |
| namespace | string | unset | Nomad namespace |
| scale | number | 1 | Number of group-instances |