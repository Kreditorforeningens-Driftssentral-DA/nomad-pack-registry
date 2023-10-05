job_name = "traefik-proxy-demo"

traefik_image = "traefik:2.5"

traefik_resources = {
  cpu        = 100
  cpu_strict = false
  memory     = 125
  memory_max = -1
}

network_mode = "host"

ports = []

consul_services_native = [{
  port = "5050"
  name = "traefik-proxy-demo"
  task = "traefik"
  
  tags = [
    "traefik-demo.enable=false",
  ]
  
  meta = {
    "metrics-prometheus-port" = "$${NOMAD_HOST_PORT_traefik}",
  }
}]

traefik_args = [
  "--global.checknewversion=false",
  "--pilot.dashboard=false",
  "--ping=true",
  "--api=true",
  "--api.dashboard=true",
  "--api.insecure=true",
  "--accesslog=true",
  "--certificatesresolvers.le-staging=true",
  "--certificatesresolvers.le-staging.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory",
  "--certificatesresolvers.le-staging.acme.storage=/secrets/acme.staging.json",
  "--certificatesresolvers.le-staging.acme.tlschallenge=true",
  "--certificatesresolvers.le=true",
  "--certificatesresolvers.le.acme.caserver=https://acme-v02.api.letsencrypt.org/directory",
  "--certificatesresolvers.le.acme.storage=/secrets/acme.json",
  "--certificatesresolvers.le.acme.tlschallenge=true",
  "--entrypoints.traefik=true",
  "--entrypoints.traefik.address=:5050",
  "--entrypoints.web=true",
  "--entrypoints.web.address=:5080",
  "--entrypoints.websecure=true",
  "--entrypoints.websecure.address=:5443",
  "--entrypoints.websecure.http.tls=true",
  "--entrypoints.websecure.http.tls.certresolver=le-staging",
  #"--providers.file.directory=/local/config",
  "--providers.consulcatalog=true",
  "--providers.consulcatalog.refreshinterval=30",
  "--providers.consulcatalog.connectaware=true",
  "--providers.consulcatalog.endpoint.datacenter=dc1",
  "--providers.consulcatalog.endpoint.address=127.0.0.1:8500",
  "--providers.consulcatalog.endpoint.scheme=http",
  "--providers.consulcatalog.servicename=traefik-proxy-demo",
  "--providers.consulcatalog.prefix=traefik-demo",
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
  data        = "Base64EncodedCertificate"
},{
  destination = "/secrets/key.pem"
  b64encode   = true
  data        = "Base64EncodedCertificateKey"
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

task_fluentbit_enabled = false