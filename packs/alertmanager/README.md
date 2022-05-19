# NOMAD-PACK: ALERTMANAGER

Creates a Prometheus alertmanager job.

You can include a [prom2teams](https://github.com/idealista/prom2teams) sidecar (python) for supporting Microsoft Teams via custom webhooks. Another alertnative is [prometheus-msteams](https://github.com/prometheus-msteams/prometheus-msteams) sidecar (golang), but not included at this time.

## Using pack
See the "vars.nomad" file for example variables

```bash
# Get latest packs & show info
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --target alertmanager
nomad-pack registry list
nomad-pack info alertmanager --registry kred-public

# Source Nomad environment & run/deploy w/custom variables from file
source nomad.env
nomad-pack run alertmanager --registry kred-public --name alertmanager -f vars.hcl

# Cleanup
nomad-pack destroy alertmanager --registry kred-public --name alertmanager -f vars.hcl
```