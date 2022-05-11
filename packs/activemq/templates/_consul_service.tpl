/////////////////////////////////////////////////
// CONSUL service
/////////////////////////////////////////////////

[[- define "consul_service" ]]

    [[- $service   := .activemq.consul_service ]]
    [[- $tags      := .activemq.consul_tags ]]
    [[- $meta      := .activemq.consul_meta ]]
    [[- $resources := .activemq.consul_sidecar_resources ]]
    [[- $upstreams := .activemq.consul_upstreams ]]
    [[- $exposes   := .activemq.consul_exposes ]]

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