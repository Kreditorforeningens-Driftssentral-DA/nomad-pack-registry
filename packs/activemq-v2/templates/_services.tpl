[[- /*
=================================================
 `service` helper

  ```
  list(
    object(
      service_name string, service_port_label string, service_provider string, service_tags list(string),
      upstreams list(object(name string, port number))
      check_type string, check_path string, check_interval string, check_timeout string
    )
  )
  ```

The template context should be set to the value of the object when calling the
template.
=================================================
*/ -]]

[[ define "service" -]]
[[ range $svc := . ]]

      service {
        name = [[ $svc.name | quote ]]
        port = [[ $svc.port_label | quote ]]
        tags = [[ $svc.tags | toStringList ]]
        
        [[- if $svc.provider ]]
        provider = [[ $svc.provider | quote ]][[- end ]]
        
        [[- if eq $svc.provider "consul" ]]
        
        connect {
          sidecar_task {
            resources {
              cpu    = [[ $svc.connect_resources.cpu ]]
              memory = [[ $svc.connect_resources.memory ]]
            }
          }

          sidecar_service {
            [[- if $svc.upstreams ]]
            proxy {
              [[- range $upstream := $svc.upstreams ]]
              upstreams {
                destination_name = [[ $upstream.name | quote ]]
                local_bind_port  = [[ $upstream.port ]]
              }
              [[- end ]]
            }
            [[- end ]]
          }
        }
        [[- end ]]
        
        [[- range $check := $svc.checks ]]
        
        check {
          type     = [[ $check.type | quote ]]
          [[- if $svc.check_path ]]
          path     = [[ $check.path | quote ]]
          [[- end ]]
          interval = [[ $check.interval | quote ]]
          timeout  = [[ $check.timeout | quote ]]
        }
        [[- end ]]
      }
[[- end ]]
[[- end ]]
