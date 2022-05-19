job_name = "demo-alertmanager"
prom2teams_enabled = true

consul_services = [{
  name = "demo-alertmanager"
  port = "9093"
  tags = ["traefik.enable=false"]
  meta = {}
  sidecar_cpu = 50
  sidecar_memory = 50
}]

alertmanager_files = [{
  destination = "/local/alertmanager.yml"
  b64encode = false
  data = <<HEREDOC
---
route:
  group_by: [ "alertname" ]
  receiver: empty # default receiver
  routes:
  - matchers: ["severity = notify"] # match on label(s) from prometheus alerts
    receiver: msteams

receivers:
- name: empty
- name: msteams
  webhook_configs:
  - url: http://localhost:8089/Connector
    send_resolved: false
HEREDOC
}]
