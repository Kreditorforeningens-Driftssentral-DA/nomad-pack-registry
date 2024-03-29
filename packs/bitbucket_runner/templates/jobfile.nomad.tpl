job "[[ template "job_name" . ]]" {
  
  [[- template "datacenters" . ]]
  [[- template "namespace" . ]]

  group "main" {
    count = [[ .my.scale ]]

    restart {
      interval = "1h"
      attempts = 3
      delay    = "60s"
      mode     = "fail"
    }

    reschedule {
      interval       = "12h"
      attempts       = 3
      delay          = "5m"
      max_delay      = "1h"
      delay_function = "exponential"
      unlimited = false
    }

    network {
      mode = "bridge"
      
      [[- range $port := .my.exposed_ports ]]
      
      port [[ $port.name | toJson ]] {
        to = [[ $port.target ]]
      }
      [[- end ]]
    }

    [[- range $svc := .my.consul_services ]]
    
    service {
      name = [[ $svc.name | toJson ]]
      port = [[ $svc.port | toJson ]]
      tags = [[ $svc.tags | toJson ]]
      connect {
        sidecar_task {
          resources {
            cpu    = [[ $svc.resources.cpu ]]
            memory = [[ $svc.resources.memory ]]
          }
        }
        sidecar_service {
          [[- if not ($svc.upstreams.services|empty) ]]
          proxy {
            [[- range $idx,$dest := $svc.upstreams.services ]]
            upstreams {
              destination_name = [[ $dest | toJson ]]
              [[- if gt $svc.upstreams.first_port 0 ]]
              local_bind_port  = [[ add $idx $svc.upstreams.first_port ]]
              [[- end ]]
            }
            [[- end ]]
          }
          [[- end ]]
        }
      }
    }
    [[- end ]]

    [[- template "task_runner" . ]]
  }
}
