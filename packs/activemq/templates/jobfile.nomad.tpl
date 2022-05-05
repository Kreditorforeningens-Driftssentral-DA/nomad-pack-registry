/////////////////////////////////////////////////
// Nomad job start ([[ template "job_name" . ]])
/////////////////////////////////////////////////

job "[[ template "job_name" . ]]" {
  [[- template "datacenters" . ]]
  [[- template "namespace" . ]]

  [[- if .activemq.constraints ]][[ range $idx, $constraint := .activemq.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    value = [[ $constraint.value | toJson ]]

    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | toJson ]]
    [[- end ]]
  }

  [[- end ]][[ end ]]

  group "main" {
    count = [[ .activemq.scale ]]

    meta {
    [[- range $k,$v := .activemq.meta ]]
      [[ $k ]] = [[ $v | toJson]]
    [[- end ]]
    }

    [[- if .activemq.ephemeral_disk ]]
    
    ephemeral_disk {
      migrate = [[ .activemq.ephemeral_disk.migrate ]]
      sticky  = [[ .activemq.ephemeral_disk.sticky ]]
      size = [[ .activemq.ephemeral_disk.size ]]
    }

    [[- end ]]
    
    network {
      mode = "bridge"
      [[- range $port := .activemq.exposed_ports ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.target ]]
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]]
        [[- end ]]
      }
      [[- end ]]
    }

    [[- range $service := .activemq.consul_services ]]

    service {
      name = [[ $service.name | toJson ]]
      port = [[ $service.port | toJson ]]
      [[- if not $service.tags | empty ]]
      tags = [[ $service.tags | toJson ]][[ end ]]
      [[- if not $service.meta | empty ]]
      meta = {
      [[- range $k,$v := $service.meta ]]
        [[ $k ]] = [[$v | toJson]]
      [[- end ]]
      }
      [[- end ]]
      connect {
        sidecar_service {
          [[- if not $service.upstreams | empty ]]
          proxy {
            [[- range $upstream := $service.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.service | toJson ]]
              local_bind_port  = [[ $upstream.local_port | toJson ]]
            }
            [[- end ]]
          }
          [[- end ]]
        }
        sidecar_task {
          resources {
            cpu = [[ default 100 $service.sidecar_cpu ]]
            memory = [[ default 128 $service.sidecar_memory ]]
          }
        }
      }
    }
    [[- end ]]

    [[- template "task_activemq" . ]]
    
    [[- if .activemq.task_enabled_postgres ]]
    [[- template "task_postgres" . ]]
    [[- end ]]

    [[- if .activemq.task_enabled_adminer ]]
    [[- template "task_adminer" . ]]
    [[- end ]]

    [[- if .activemq.task_enabled_telegraf ]]
    [[- template "task_telegraf" . ]]
    [[- end ]]
  }
}