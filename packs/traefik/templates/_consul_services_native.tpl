//////////////////////////////////
// CONSUL native services
//////////////////////////////////

[[- define "consul_services_native" ]]

  [[- range $idx, $service := .my.consul_services_native ]]
  
    service {
      port = [[ $service.port | toJson ]]
      name = [[ $service.name | toJson ]]
      
      [[- if $service.task ]]
      task = [[ $service.task | toJson ]][[ end ]]
      
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