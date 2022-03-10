# nomad-pack-registry
[Public nomad-pack registry ](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs)

## Details

Public nomad-pack registry

## Usage
```bash
# Locally (dev)
source nomad-test.env
nomad-pack render -name demo -var job_name=demo packs/example
nomad-pack plan -name demo -var job_name=demo packs/example
nomad-pack run -name demo -var job_name=demo packs/example
nomad-pack stop -purge -name demo -var job_name=demo packs/example
```


## Refs

  * [Go-template syntax](https://learn.hashicorp.com/tutorials/nomad/go-template-syntax)
  * [Go Text/template-functions](https://pkg.go.dev/text/template)
  * [Nomad-pack template-functions](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs#template-functions)
  * [Sprig template-functions](http://masterminds.github.io/sprig/)
