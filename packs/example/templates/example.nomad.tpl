/////////////////////////////////////////////////
// Nomad job start ([[ template "job_name" . ]])
/////////////////////////////////////////////////

job "[[ template "job_name" . ]]" {
  [[- template "datacenters" . ]]
  [[- template "namespace" . ]]

  group "main" {
    count = [[ .example.scale ]]
    
    [[- template "task_web" . ]]

    network {
      mode = "bridge"
      [[- range $port := .example.exposed_ports ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.target ]]
      }
      [[- end ]]
    }

    [[- range $svc := .example.consul_services ]]

    service {
      name = [[ $svc.name | toJson ]]
      port = [[ $svc.port | toJson ]]
[[ cat "tags" "=" ($svc.tags|toPrettyJson) | print | indent 6 ]]
      connect {
        sidecar_task {
          resources {
            cpu    = [[ $.example.consul_sidecar_resources.cpu ]]
            memory = [[ $.example.consul_sidecar_resources.memory ]]
          }
        }
        sidecar_service {
          [[- if $.example.consul_upstreams | empty | not ]]
          proxy {
            [[- range $idx,$ups := $.example.consul_upstreams.services ]]
            upstreams {
              destination_name = [[ $ups | toJson ]]
              local_bind_port  = [[ add $idx $.example.consul_upstreams.first_port ]]
            }
            [[- end ]]
          }
          [[- end ]]
        }
      }
    }

    [[- end ]]
  }
}