job "[[ template "job_name" . ]]" {
  datacenters = [[ .my.datacenters | toStringList ]]

  [[- if $namespace := .my.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]

  [[- if $region := .my.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .my.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    operator  = [[ $constraint.operator | toJson ]]
    value     = [[ $constraint.value | toJson ]]
  }
  [[- end ]]

  group "main" {
    count = [[ .my.instances ]]

    restart {
      interval = "30m"
      attempts = 3
      delay    = "15s"
      mode     = "fail"
    }

    update {
      max_parallel      = 1
      health_check      = "checks"
      min_healthy_time  = "10s"
      healthy_deadline  = "5m"  // this allocation
      progress_deadline = "10m" // any allocation
      auto_revert       = true
    }

    [[- if $disk := .my.ephemeral_disk ]]
    
    ephemeral_disk {
      [[- if $disk.size ]]
      size = [[ $disk.size ]][[ end ]]
      
      [[- if $disk.migrate ]]
      migrate = [[ $disk.migrate ]][[ end ]]
      
      [[- if $disk.sticky ]]
      sticky = [[ $disk.sticky ]][[ end ]]
    }
    
    [[- end ]]
    
    network {
      mode = "bridge"
      
      [[- range $port := .my.ports ]]
      port [[ $port.label | toJson ]] {
        to = [[ $port.to ]]
        
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]][[ end ]]
      }
      [[- end ]]
      
      [[- range $port := .my.connect_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- if .my.consul_services ]]
    [[- template "consul_services" . ]][[ end ]]

    [[- if .my.prom2teams_enabled ]]
    [[- template "task_prom2teams" . ]][[ end ]]
  }
}
