job "[[ template "job_name" . ]]" {
  
  datacenters = [[ .payara_server.datacenters | toStringList ]]

  [[- if $namespace := .payara_server.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .payara_server.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- if .payara_server.constraints ]][[ range $idx, $constraint := .payara_server.constraints ]]

  constraint {
    [[- if ne $constraint.attribute "" ]]
    attribute = [[ $constraint.attribute | toJson ]][[ end ]]
    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | toJson ]]
    [[- end ]]
    value = [[ $constraint.value | toJson ]]
  }

  [[- end ]][[ end ]]

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "10m"  // this allocation
    progress_deadline = "15m" // any allocation
    auto_revert       = true
  }

  group "main" {
    [[- if ne ($scale := .payara_server.scale) 1 ]]
    count = [[ $scale ]][[ end ]]

    restart {
      interval = "30m"
      attempts = 3
      delay    = "10m" // +25% random jitter
      mode     = "fail"
    }

    meta {
    [[- range $k,$v := .payara_server.meta ]]
      [[ $k ]] = [[ $v | toJson]]
    [[- end ]]
    }

    [[- if .payara_server.ephemeral_disk ]]
    
    ephemeral_disk {
      migrate = [[ .payara_server.ephemeral_disk.migrate ]]
      size = [[ .payara_server.ephemeral_disk.size ]]
      sticky = [[ .payara_server.ephemeral_disk.sticky ]]
    }

    [[- end ]]
    
    network {
      mode = "bridge"
      
      [[- range $port := .payara_server.consul_exposes ]]
      port [[ $port.name | toJson ]] {}[[ end ]]
      
      [[- range $port := .payara_server.ports ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.to ]]
        [[- if (gt $port.static 0) ]]
        static = [[ $port.static ]][[- end ]]
      }
      [[- end ]]
    }

    [[- if .payara_server.consul_service ]]
    [[- template "consul_service_payara" . ]]
    [[- end ]]

    [[- template "task_payara" . ]]
    
    [[- if .payara_server.task_enabled_maven ]]
    [[- template "task_maven" . ]]
    [[- end ]]
    
    [[- if .payara_server.task_enabled_fluentbit ]]
    [[- template "task_fluentbit" . ]]
    [[- end ]]
  }
}