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

    [[- if .example.consul_service | empty | not ]]
      
      [[- $svc := .example.consul_service ]]
      [[- $res := .example.consul_sidecar_resources ]]
      [[- $ups := .example.consul_upstreams ]]

    service {
      name = [[ $svc.name | toJson ]]
      port = [[ $svc.port | toJson ]]
      tags = [[ $svc.tags | toJson ]]
      connect {
        sidecar_task {
          resources {
            cpu = [[ default 100 $res.cpu ]]
            memory = [[ default 32 $res.memory ]]
          }
        }
        sidecar_service {
          [[- if $ups | empty | not ]]
          proxy {
            [[- range $idx,$dest := $ups.services ]]
            upstreams {
              destination_name = [[ $dest | toJson ]]
              local_bind_port  = [[ add $idx $ups.port_start ]]
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