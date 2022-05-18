# GRAFANA PACK

Creates a Traefik Edge Proxy job. Features:

  * Configure traefik using file, flags & env.
  * Supports Consul connect native (optional).

## Example

```bash
# Run (locally)
nomad-pack run packs/traefik --name demo-traefik-native -f example-native.hcl

# Testing
watch 'curl -H "Host: traefik-v2-demo" http://<traefik-host:port>'
```

```hcl
#example-native.hcl
job_name = "demo-traefik-v2-proxy"

# Only included for testing. Requires:
# "--providers.consulcatalog.prefix=traefik-v2" on traefik config
group_demo_enabled = true

consul_services_native = [{
  port = "8080"
  name = "traefik-v2-proxy"
  tags = ["traefik-v2.enable=false"]
  meta = {
    "metrics-prometheus-port" = "$${NOMAD_HOST_PORT_console}",
  }
}]

# Can't mix native & sidecar
#consul_services = []

ports = [{
  label = "console"
  to = 8080
  static = 8080
},{
  label = "http"
  to = 80
  static = 80
},{
  label = "https"
  to = 443
  static = 443
}]

traefik_args = [
  "--accesslog=true",
  "--api=true",
  "--api.dashboard=true",
  "--api.insecure=true",
  "--certificatesresolvers.LE=true",
  "--certificatesresolvers.LE.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory",
  "--certificatesresolvers.LE.acme.storage=/secrets/acme.LE.json",
  "--entrypoints.http=true",
  "--entrypoints.http.address=:80",
  "--entrypoints.http.forwardedheaders.insecure=true",
  "--entrypoints.https=true",
  "--entrypoints.https.address=:443",
  "--providers.consulcatalog=true",
  "--providers.consulcatalog.refreshinterval=15",
  "--providers.consulcatalog.connectaware=true",
  "--providers.consulcatalog.servicename=traefik-v2-proxy",
  "--providers.consulcatalog.prefix=traefik-v2",
  "--providers.consulcatalog.exposedbydefault=false",
  "--providers.consulcatalog.connectbydefault=true",
  "--metrics.prometheus=true",
  "--metrics.prometheus.entryPoint=traefik",
  "--metrics.prometheus.addEntryPointsLabels=true",
  "--metrics.prometheus.addrouterslabels=false",
  "--metrics.prometheus.addServicesLabels=true",
]
```
