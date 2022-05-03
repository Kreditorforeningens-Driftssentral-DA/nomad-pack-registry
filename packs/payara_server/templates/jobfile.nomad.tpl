/////////////////////////////////////////////////
// Nomad job start ([[ template "job_name" . ]])
/////////////////////////////////////////////////

job "[[ template "job_name" . ]]" {
  [[- template "datacenters" . ]]
  [[- template "namespace" . ]]

  [[- if .payara_server.constraints ]][[ range $idx, $constraint := .payara_server.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    value = [[ $constraint.value | toJson ]]

    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | toJson ]]
    [[- end ]]
  }

  [[- end ]][[ end ]]

  group "main" {
    count = [[ .payara_server.scale ]]

    [[- if .payara_server.ephemeral_disk ]]
    
    ephemeral_disk {
      migrate = [[ .payara_server.ephemeral_disk.migrate ]]
      size = [[ .payara_server.ephemeral_disk.size ]]
      sticky  = [[ .payara_server.ephemeral_disk.sticky ]]
    }

    [[- end ]]
    
    network {
      mode = "bridge"
      [[- range $port := .payara_server.exposed_ports ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.target ]]
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]]
        [[- end ]]
      }
      [[- end ]]
    }

    [[- range $service := .payara_server.consul_services ]]

    service {
      name = [[ $service.name | toJson ]]
      port = [[ $service.port | toJson ]]
      tags = [[ $service.tags | toJson ]]
      connect {
        sidecar_service {
          
          proxy {
            [[- range $upstream := $service.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.service | toJson ]]
              local_bind_port  = [[ $upstream.local_port | toJson ]]
              datacenter = "dc2"
              local_bind_address = "127.0.0.1"
              mesh_gateway {
                mode = "local"
              }
            }
            [[- end ]]
          }
        }
        [[- if not $service.sidecar_resources | empty ]]
        sidecar_task {
          resources {
            cpu = [[ $service.sidecar_resources.cpu ]]
            memory = [[ $service.sidecar_resources.memory ]]
          }
        }
        [[- end ]]
      }
    }

    [[- end ]]

    [[- template "task_payara" . ]]
    [[- if .payara_server.task_enabled_fluentbit_maven ]]
    [[- template "task_maven" . ]]
    [[- end ]]
    [[- if .payara_server.task_enabled_fluentbit ]]
    [[- template "task_fluentbit" . ]]
    [[- end ]]
  }
}