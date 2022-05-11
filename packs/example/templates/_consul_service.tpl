/////////////////////////////////////////////////
// CONSUL service
/////////////////////////////////////////////////

[[- define "consul_service" ]]

    [[- $service   := .my.consul_service ]]
    [[- $tags      := .my.consul_tags ]]
    [[- $meta      := .my.consul_meta ]]
    [[- $no_checks := .my.consul_checks_disabled ]]
    [[- $resources := .my.consul_resources ]]
    [[- $upstreams := .my.consul_upstreams ]]
    [[- $exposes   := .my.consul_exposes ]]

    service {
      name = [[ $service.name | toJson ]]
      port = [[ $service.port | toJson ]]

      [[- if $tags ]]
      
      tags = [[ $tags | toStringList ]][[ end ]]

      [[- if $meta ]]
      
      meta {
        [[- range $k,$v := $meta ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      [[- if not $no_checks ]]
      
      check {
        type = "tcp"
        interval = "15s"
        timeout = "5s"
        
        check_restart {
          limit = 3
          grace = "30s"
          ignore_warnings = false
        }
      }

      [[- end ]]
      
      [[- if $service.connect ]]
      
      connect {
        sidecar_service {
          [[- if (or $upstreams $exposes) ]]
          proxy {
            [[- if $exposes ]]
            expose {
              
              [[- range $expose := $exposes ]]
              path {
                path = [[ $expose.path | toJson ]]
                protocol = "http"
                local_path_port = [[ $expose.local_port ]]
                listener_port = [[ $expose.port_label | toJson ]]
              }
              [[- end ]]
            }
            [[- end ]]
            
            [[- range $upstream := $upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | toJson ]]
              local_bind_port = [[ $upstream.local_port ]]
            }
            [[- end ]]
          }
          [[- end ]]
        }

        sidecar_task {
          [[- if $resources ]]
          resources {
            cpu = [[ $resources.cpu ]]
            memory = [[ $resources.memory ]]
          }
          [[- end ]]
        }
      }
      [[- end ]]
    }

[[- end ]]