job_name = "demo-alertmanager"
prom2teams_enabled = true

consul_services = [{
  name = "alert2teams"
  port = "9093"
  meta = {}
  sidecar_cpu = 50
  sidecar_memory = 65
  
  tags = [
    "traefik.enable=false"
  ]
}]
