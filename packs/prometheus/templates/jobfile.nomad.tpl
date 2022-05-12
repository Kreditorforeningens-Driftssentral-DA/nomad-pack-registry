job "[[ template "job_name" . ]]" {
  datacenters = [[ .prometheus.datacenters | toStringList ]]
  
  [[- if $namespace := .prometheus.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .prometheus.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .prometheus.constraints ]]
  
  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    operator  = [[ $constraint.operator | toJson ]]
    value     = [[ $constraint.value | toJson ]]
  }
  [[- end ]]

  group "main" {
    count = [[ .prometheus.instances ]]

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

    [[- if $disk := .prometheus.ephemeral_disk ]]
    
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
      
      [[- range $port := .prometheus.ports ]]
      port [[ $port.label | toJson ]] {
        to = [[ $port.to ]]
        
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]][[ end ]]
      }
      [[- end ]]
      
      [[- range $port := .prometheus.connect_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- if .prometheus.consul_services ]]
    [[- template "consul_services" . ]][[ end ]]

    [[- template "task_prometheus" . ]]
  }
}
