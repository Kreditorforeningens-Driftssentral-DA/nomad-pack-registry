/////////////////////////////////////////////////
// CONSUL SERVICE loki
/////////////////////////////////////////////////

[[- define "consul_service_loki" ]]

    service {
      name = [[ .loki.consul_service.name | toJson ]]
      port = [[ .loki.consul_service.port | toJson ]]
      tags = [[ .loki.consul_service_tags | toStringList ]]
      
      [[- if .loki.consul_service_meta ]]
      
      meta {
        [[- range $k,$v := .loki.consul_service_meta ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]
      [[- range $check := .loki.consul_checks ]]
      
      check {
        name = [[ $check.name | toJson ]]
        type = "http"
        interval = "15s"
        timeout  = "5s"
        path = [[ $check.path | toJson ]]
        [[- if $.loki.ports | empty ]]
        expose = true[[ end ]]
      }
      
      [[- end ]]
      
      connect {
        sidecar_task {
          resources {
            cpu = [[ .loki.consul_sidecar_resources.cpu ]]
            memory = [[ .loki.consul_sidecar_resources.cpu ]]
          }
        }
        sidecar_service {
          proxy {
            [[- range $upstream := .loki.consul_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | toJson ]]
              local_bind_port  = [[ $upstream.bind_port ]]
            }
            [[- end ]]
            [[- if .loki.consul_exposes ]]
            expose {
              [[- range $expose := .loki.consul_exposes ]]
              path {
                protocol        = "http"
                path            = [[ $expose.path | toJson ]]
                listener_port   = [[ $expose.name | toJson ]]
                local_path_port = [[ $expose.port ]]
              }
              [[- end ]]
            }
            [[- end ]]
          }
        }
      }
    }

[[- end ]]