job "[[ template "job_name" . ]]" {
  
  datacenters = [[ .payara_server.datacenters | toStringList ]]

  [[- if $namespace := .payara_server.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .payara_server.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $idx, $constraint := .payara_server.constraints ]]

  constraint {
    
    [[- if ne $constraint.attribute "" ]]
    attribute = [[ $constraint.attribute | toJson ]][[ end ]]
    
    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | toJson ]]
    
    [[- end ]]
    value = [[ $constraint.value | toJson ]]
  }

  [[- end ]]

  group "main" {
    
    [[- if ne ($scale := .payara_server.scale) 1 ]]
    count = [[ $scale ]][[ end ]]

    [[- with .payara_server.restart_policy ]]

    restart {
      interval = [[ .interval | quote ]]
      attempts = [[ .attempts ]]
      delay    = [[ .delay | quote ]]
      mode     = [[ .mode | quote ]]
    }

    [[- end ]]

    meta {
    [[- range $k,$v := .payara_server.meta ]]
      [[ $k ]] = [[ $v | toJson]]
    [[- end ]]
    }

    [[- if $disk := .payara_server.ephemeral_disk ]]
    
    ephemeral_disk {
      size = [[ $disk.size ]]
      migrate = [[ $disk.migrate ]]
      sticky = [[ $disk.sticky ]]
    }

    [[- end ]]
    
    network {
      mode = "bridge"
      
      [[- range $port := .payara_server.ports ]]
      port [[ $port.label | toJson ]] {
        to = [[ $port.to ]]
        [[- if (gt $port.static 0) ]]
        static = [[ $port.static ]][[- end ]]
      }
      [[- end ]]

      [[- range $port := .payara_server.connect_exposes ]]
      port [[ $port.port_label | toJson ]] {}[[ end ]]
    }

    [[- template "consul_services" . ]]
    
    [[- if .payara_server.task_enabled_maven ]]
    [[- template "task_maven" . ]][[ end ]]
    
    [[- if .payara_server.task_enabled_fluentbit ]]
    [[- template "task_fluentbit" . ]][[ end ]]

    [[- template "task_payara" . ]]
  }

  [[- with .payara_server.update_policy ]]

  update {
    auto_revert       = [[ .auto_revert ]]
    max_parallel      = [[ .max_parallel ]]
    health_check      = [[ .health_check | quote ]]
    min_healthy_time  = [[ .min_healthy_time | quote ]]
    healthy_deadline  = [[ .healthy_deadline | quote ]]
    progress_deadline = [[ .progress_deadline | quote ]]
  }

  [[- end ]]
}