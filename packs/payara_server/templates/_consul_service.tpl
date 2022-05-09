/////////////////////////////////////////////////
// CONSUL service
/////////////////////////////////////////////////

[[- define "consul_service_payara" ]]

    service {
      name = [[ .payara_server.consul_service.name | toJson ]]
      port = [[ .payara_server.consul_service.port | toJson ]]
      tags = [[ .payara_server.consul_service_tags | toStringList ]]
      
      [[- if .payara_server.consul_service_meta ]]
      
      meta {
        [[- range $k,$v := .payara_server.consul_service_meta ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]
      
      [[- range $check := .payara_server.consul_checks ]]
      
      check {
        name = [[ $check.name | toJson ]]
        type = "http"
        interval = "15s"
        timeout = "5s"
        path = [[ $check.path | toJson ]]
        [[- if $check.port ]]
        port = [[ $check.port | toJson ]][[- end ]]
        [[- if $check.expose ]]
        expose = true[[ end ]]
      }
      
      check_restart {
        limit = 3
        grace = "300s"
      }
      
      [[- end ]]
      
      connect {
        sidecar_task {
          resources {
            cpu = [[ .payara_server.consul_sidecar_resources.cpu ]]
            memory = [[ .payara_server.consul_sidecar_resources.cpu ]]
          }
        }
        sidecar_service {
          proxy {
            [[- range $upstream := .payara_server.consul_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | toJson ]]
              local_bind_port  = [[ $upstream.bind_port ]]
            }
            [[- end ]]

            [[- if .payara_server.consul_exposes ]]
            expose {
              [[- range $expose := .payara_server.consul_exposes ]]
              path {
                protocol        = "http"
                path            = [[ $expose.path | toJson ]]
                listener_port   = [[ $expose.name | toJson ]] // Name/label of group-port to bind
                local_path_port = [[ $expose.port ]] // Target task-port with path to expose
              }
              [[- end ]]
            }
            [[- end ]]
          }
        }
      }
    }

[[- end ]]