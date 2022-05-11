# PACK: EXAMPLE

## How to use
```bash
# Requires nomad-pack 0.0.1-techpreview3 (nightly) or newer
nomad-pack --help
nomad-pack version

# Local
nomad-pack render  packs/example/ --var-file packs/example/vars.nomad
nomad-pack plan    packs/example/ --var-file packs/example/vars.nomad
nomad-pack run     packs/example/ --var-file packs/example/vars.nomad
nomad-pack destroy packs/example/ --var-file packs/example/vars.nomad

# Via Registry
nomad-pack registry add custom-packs https://github.com/Kreditorforeningens-Driftssentral-DA/nomad-pack-registry
nomad-pack registry list
nomad-pack render example --registry custom-packs --var-file packs/example/vars.nomad
nomad-pack render example --registry custom-packs --var-file packs/example/vars.nomad

```

## Info
> ".my": See https://discuss.hashicorp.com/t/nomad-pack-root-function-variable/39240
