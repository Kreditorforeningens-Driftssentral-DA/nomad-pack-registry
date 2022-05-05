job "[[ template "job_name" . ]]" {
  [[- template "datacenters" . ]]

  type      = "service"
  priority  = [[ .grafana.priority ]]
  namespace = [[ .grafana.namespace | toJson ]]  
  region    = [[ .grafana.region | toJson ]]

  [[- if .grafana.constraints ]][[ range $idx, $constraint := .grafana.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    value     = [[ $constraint.value | toJson ]]

    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | toJson ]]
    [[- end ]]
  }

  [[- end ]][[ end ]]

  group "main" {

    network {
      mode = "bridge"
      [[- if gt .grafana.http_port 0 ]]
      port "http" {
        to = [[ .grafana.http_port ]]
      }
      [[- end ]]
    }

    [[- if not .grafana.ephemeral_disk | empty ]]

    ephemeral_disk {
      migrate = [[ .grafana.ephemeral_disk.migrate ]]
      sticky = [[ .grafana.ephemeral_disk.sticky ]]
      size = [[ .grafana.ephemeral_disk.size ]]
    }

    [[- end ]]

    [[- if not .grafana.consul_service | empty ]]
    
    service {
      port = [[ .grafana.consul_service.port ]]
      name = [[ .grafana.consul_service.name | toJson ]]
      tags = [[ .grafana.consul_service.tags | toJson ]]
      connect {
        sidecar_task {
          resources {
            cpu    = [[ .grafana.consul_service.sidecar_cpu ]]
            memory = [[ .grafana.consul_service.sidecar_memory ]]
          }
        }
        sidecar_service {
          [[- if not .grafana.consul_service.upstreams | empty ]]
          proxy {
            [[- range $upstream := .grafana.consul_service.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.service | toJson ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
          [[- end ]]
        }
      }
    }

    [[- end ]]
    [[- template "task_grafana" . ]]
  }
}
