# NOMAD-PACK-REGISTRY (PUBLIC)

## Details

List of packs in this repository:
  
  * [Bitbucket-Runner](packs/bitbucket_runner/README.md)
  * [Grafana](packs/grafana/README.md)

## Usage

```bash
# Use packs locally (dev)
source nomad-test.env
nomad-pack render -name demo -var job_name=demo packs/example
nomad-pack plan -name demo -var job_name=demo packs/example
nomad-pack run -name demo -var job_name=demo packs/example
nomad-pack stop -purge -name demo -var job_name=demo packs/example

# Add (public) pack registry
nomad-pack registry add -h
nomad-pack registry add kred-public https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry
nomad-pack registry list
nomad-pack render bitbucket_runner --registry=kred-public --ref=latest
```

## References for writing packs

  * [public nomad-pack registry ](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs)
  * [Go-template syntax](https://learn.hashicorp.com/tutorials/nomad/go-template-syntax)
  * [Go Text/template-functions](https://pkg.go.dev/text/template)
  * [Nomad-pack template-functions](https://learn.hashicorp.com/tutorials/nomad/nomad-pack-writing-packs#template-functions)
  * [Sprig template-functions](http://masterminds.github.io/sprig/)
