# payara_server

This is a pack for deploying Payara Server (Community Edition)
Optionally, you can deploy maven and/or fluentbit sidecars.


## Pack Usage

```bash
# Add pack-registry
nomad-pack registry add kred-no https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --target payara-server-v2 --ref payara-server-v2_0.1.0
nomad-pack list

# Validate pack
nomad-pack info payara-server-v2 --registry=kred-no
nomad-pack render payara-server-v2 --registry=kred-no
```

## Variables

```bash
# Generate default var-file
nomad-pack generate var-file payara-server-v2 -o vars.hcl --registry=kred-no
```

#### JOB ALLOCATION

| Variable Name    | Type            | Required | Description |
| :--              | :--             | :-:      | :--         |
| `constraints`    | list(object)    | No       | Constraints on job placement |
| `datacenters`    | list(string)    | No       | Nomad datacenters |
| `ephemeral_disk` | object          | No       | N/A |
| `job_name`       | string          | No       | Nomad Job-name. Defaults to pack-name |
| `namespace`      | string          | No       | Nomad namespace |
| `network_mode`   | string          | No       | N/A |
| `ports`          | list(object)    | No       | N/A |
| `region`         | string          | No       | Nomad region |
| `services`       | list(object)    | No       | N/A |


#### PAYARA SERVER (LEADER TASK)

| Variable Name      | Type            | Required | Description |
| :--                | :--             | :-:      | :--         |
| `payara_env`       | map(string)     | No       | N/A |
| `payara_files`     | list(object)    | No       | N/A |
| `payara_image`     | string          | No       | N/A |
| `payara_resources` | object          | No       | N/A |


#### MAVEN (SIDECAR-TASK)

| Variable Name     | Type            | Required | Description |
| :--               | :--             | :-:      | :--         |
| `maven_config`    | object          | No       | N/A |
| `maven_enabled`   | bool            | No       | N/A |
| `maven_env`       | map(string)     | No       | N/A |
| `maven_image`     | string          | No       | N/A |
| `maven_resources` | object          | No       | N/A |


#### FLUENTBIT (SIDECAR-TASK)

| Variable Name         | Type            | Required | Description |
| :--                   | :--             | :-:      | :--         |
| `fluentbit_config`    | list(object)    | No       | N/A |
| `fluentbit_enabled`   | bool            | No       | N/A |
| `fluentbit_env`       | map(string)     | No       | N/A |
| `fluentbit_image`     | string          | No       | N/A |
| `fluentbit_resources` | object          | No       | N/A |

---
[pack-registry]: https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry
[community-registry]: https://github.com/hashicorp/nomad-pack-community-registry
