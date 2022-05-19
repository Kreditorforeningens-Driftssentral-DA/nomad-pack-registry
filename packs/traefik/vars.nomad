job_name = "demo-traefik-v2-proxy"

group_demo_enabled = false

traefik_resources = {
  cpu = 100
  cpu_strict = false
  memory = 125
  memory_max = 250
}

consul_services_native = [{
  port = "8080"
  name = "traefik-v2-proxy"
  task = "traefik"
  tags = ["traefik-v2.enable=false"]
  meta = {
    "metrics-prometheus-port" = "$${NOMAD_HOST_PORT_console}",
  }
}]

consul_services = []

ports = [{
  label = "console"
  to = 8080
  static = 4088
},{
  label = "http"
  to = 80
  static = 4080
},{
  label = "https"
  to = 443
  static = 4443
}]

# When using connect native task, traefik manages the connection:
#"--providers.consulcatalog.endpoint.address=172.17.0.1:8500",
#"--providers.consulcatalog.endpoint.scheme=http",

traefik_args = [
  "--global.checknewversion=false",
  "--pilot.dashboard=false",
  "--ping=true",
  "--api=true",
  "--api.dashboard=true",
  "--api.insecure=true",
  "--accesslog=true",
  "--certificatesresolvers.LE=true",
  "--certificatesresolvers.LE.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory",
  "--certificatesresolvers.LE.acme.storage=/secrets/acme.LE.json",
  "--certificatesresolvers.LE.acme.tlschallenge=true",
  "--entrypoints.http=true",
  "--entrypoints.http.address=:80",
  "--entrypoints.http.forwardedheaders.insecure=true",
  "--entrypoints.https=true",
  "--entrypoints.https.address=:443",
  "--providers.file.directory=/local/config"
  "--providers.consulcatalog=true",
  "--providers.consulcatalog.refreshinterval=30",
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

traefik_files = [{
  destination = "/secrets/cert.pem"
  b64encode   = true
  data        = "SomeCertificate"
},{
  destination = "/secrets/key.pem"
  b64encode   = true
  data        = "SomeCertificateKey"
},{
  destination = "/local/config/traefik.yml"
  b64encode   = false
  data        = <<-HEREDOC
  tls:
    certificates:
    - certFile: /secrets/cert.pem
      keyFile: /secrets/key.pem
  HEREDOC
}]
