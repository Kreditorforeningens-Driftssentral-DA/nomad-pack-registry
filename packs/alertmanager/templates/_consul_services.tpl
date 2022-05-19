//////////////////////////////////
// CONSUL services
//   Connect upstreams &
//   exposes are included for the 
//   FIRST service
//////////////////////////////////

[[- define "consul_services" ]]

  [[- $exposes   := .alertmanager.connect_exposes ]]
  [[- $upstreams := .alertmanager.connect_upstreams ]]

  [[- range $idx, $service := .alertmanager.consul_services ]]
  
    service {
      port = [[ $service.port | toJson ]]
      name = [[ $service.name | toJson ]]
      
      [[- if $service.tags ]]
      
      tags = [[ $service.tags | toStringList ]][[ end ]]
      
      [[- if $service.meta ]]
      
      meta {
        [[- range $k,$v := $service.meta ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      } 
      
      [[- end ]]
      
      connect {
        sidecar_service {
          [[- if eq $idx 0 ]][[- if (or $upstreams $exposes) ]]
          proxy {
            
            [[- if $exposes ]]
            expose {
              
              [[- range $expose := $exposes ]]
              path {
                protocol = "http"
                path = [[ $expose.path | toJson ]]
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
          [[- end ]][[ end ]]
        }
        
        sidecar_task {
          resources {
            cpu    = [[ $service.sidecar_cpu ]]
            memory = [[ $service.sidecar_memory ]]
          }
        }
      }
    }
  [[- end ]]

[[- end ]]