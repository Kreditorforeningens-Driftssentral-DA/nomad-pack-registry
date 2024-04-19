# ACTIVEMQ

<!-- Include a brief description of your pack -->


## PACK USAGE

<!-- Include information about how to use your pack -->

```bash
# Add pack-registry
nomad-pack registry add kred https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry --target=activemq-v2 --ref=activemq-v2_0.1.0
nomad-pack list

# Validate pack
nomad-pack render activemq-v2 --registry=kred

# Generate var-file
nomad-pack generate var-file activemq-v2 -o vars.hcl --registry=kred
```

## VARIABLES

<!-- Include information on the variables from your pack -->

| Variable Name      | Type            | Required | Description        |
| :--                | :--             | :-:      | :--                |
| job_name           | string          | No       | N/A                |
| region             | string          | No       | N/A                |
| namespace          | string          | No       | N/A                |
| datacenters        | list(string)    | No       | N/A                |
| constraints        | list(object)    | No       | N/A                |


### Deployment Group

| Variable Name      | Type            | Required | Description        |
| :--                | :--             | :-:      | :--                |
| network_mode       | string          | No       | N/A                |
| ports              | list(object)    | No       | N/A                |
| services           | list(object)    | No       | N/A                |


### ActiveMQ Task

| Variable Name      | Type            | Required | Description        |
| :--                | :--             | :-:      | :--                |
| activemq_image     | string          | No       | N/A                |
| activemq_resources | object          | No       | N/A                |
| activemq_env       | map(string)     | No       | N/A                |
| activemq_files     | list(object)    | No       | N/A                |


### Telegraf Task

| Variable Name      | Type            | Required | Description        |
| :--                | :--             | :-:      | :--                |
| telegraf_enabled   | bool            | No       | N/A                |
| telegraf_image     | string          | No       | N/A                |
| telegraf_resources | object          | No       | N/A                |
| telegraf_env       | map(string)     | No       | N/A                |
| telegraf_config    | object          | No       | N/A                |


### FluentBit Task

| Variable Name       | Type            | Required | Description        |
| :--                 | :--             | :-:      | :--                |
| fluentbit_enabled   | bool            | No       | N/A                |
| fluentbit_image     | string          | No       | N/A                |
| fluentbit_resources | object          | No       | N/A                |
| fluentbit_env       | map(string)     | No       | N/A                |
| fluentbit_config    | list(object)    | No       | N/A                |


[pack-registry]: https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry
[community-pack-registry]: https://github.com/hashicorp/nomad-pack-community-registry
