//////////////////////////////////
// CONSUL native services
//////////////////////////////////

[[- define "consul_services_native" ]]

  [[- range $idx, $service := .traefik.consul_services_native ]]
  
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
        native = true
      }
    }
  [[- end ]]

[[- end ]]