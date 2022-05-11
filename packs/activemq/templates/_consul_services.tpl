/////////////////////////////////////////////////
// CONSUL service
/////////////////////////////////////////////////

[[- define "consul_services" ]]
[[- range $service := .activemq.consul_services ]]

    service {
      name = [[ $service.name | toJson ]]
      port = [[ $service.port | toJson ]]

      [[- if $tags := $service.tags ]]
      
      tags = [[ $tags | toStringList ]][[ end ]]

      [[- if $meta := $service.meta ]]
      
      meta {
        [[- range $k,$v := $meta ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      connect {
        sidecar_service {}
        sidecar_task {
          resources {
            cpu = [[ $service.sidecar_cpu ]]
            memory = [[ $service.sidecar_memory ]]
          }
        }
      }
    }

[[- end ]]
[[- end ]]