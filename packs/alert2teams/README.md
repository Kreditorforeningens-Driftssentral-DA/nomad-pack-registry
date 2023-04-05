# NOMAD-PACK: ALERT2TEAMS

Creates a job for forwarding alertmanager webhook alerts to teams webhooks.

* Supported: [prom2teams](https://github.com/idealista/prom2teams).
* TODO: [prometheus-msteams](https://github.com/prometheus-msteams/prometheus-msteams).

## Using pack
See the "vars.nomad" file for example variables

```bash
# Get latest packs & show info
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --target alert2teams
nomad-pack registry list
nomad-pack info alert2teams --registry kred-public

# Source Nomad environment & run/deploy w/custom variables from file
source nomad.env
nomad-pack run alert2teams --registry kred-public --name alert2teams -f vars.hcl

# Cleanup
nomad-pack destroy alert2teams --registry kred-public --name alert2teams -f vars.hcl
```
