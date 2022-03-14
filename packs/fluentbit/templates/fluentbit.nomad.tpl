/////////////////////////////////////////////////
// NOMAD job
/////////////////////////////////////////////////

job "[[ template "job_name" . ]]" {
  
  [[- template "datacenters" . ]]
  [[- template "namespace" . ]]

  group "main" {
    count = [[ .fluentbit.scale ]]
    
    network {
      mode = "bridge"
      [[- range $port := .fluentbit.exposed_ports ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.target ]]
      }
      [[- end ]]
    }

    [[- range $svc := .fluentbit.consul_services ]]
      
    service {
      name = [[ $svc.name | toJson ]]
      port = [[ $svc.port | toJson ]]
      tags = [[ $svc.tags | toJson ]]
      
      connect {
        
        sidecar_task {
          resources {
            cpu = [[ default 100 $svc.resources.cpu ]]
            memory = [[ default 32 $svc.resources.memory ]]
          }
        }
        
        sidecar_service {
          [[- if not $svc.upstreams.targets | empty ]]
          proxy {
            [[- range $idx,$target := $svc.upstream.targets ]]
            upstreams {
              destination_name = [[ $target | toJson ]]
              local_bind_port  = [[ add $idx $svc.upstreams.first_port ]]
            }
            [[- end ]]
          }
          [[- end ]]
        }
      }
    }

    [[- end ]]

    [[- template "task_fluentbit" . ]]
  
  } //END group
} // END job