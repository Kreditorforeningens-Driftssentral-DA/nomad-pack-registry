/////////////////////////////////////////////////
// NOMAD job
/////////////////////////////////////////////////

job "[[ template "job_name" . ]]" {
  
  datacenters = [[ .loki.datacenters | toStringList ]]
  [[- if $namespace := .loki.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  [[- if $region := .loki.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .loki.constraints ]]
  
  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    operator  = [[ $constraint.operator | toJson ]]
    value     = [[ $constraint.value | toJson ]]
  }
  [[- end ]]

  group "main" {
    count = [[ .loki.scale ]]

    restart {
      interval = "15m"
      attempts = 2
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

    [[- if $disk := .loki.ephemeral_disk ]]
    
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
      [[- range $port := .loki.consul_exposes ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
      [[- range $port := .loki.ports ]]
      port [[ $port.name | toJson ]] {
        to = [[ $port.to ]]
        [[- if (gt $port.static 0) ]]
        static = [[ $port.static ]][[- end ]]
      }

      [[- end ]]
    }

    [[- if .loki.consul_service ]][[- template "consul_service_loki" . ]]  
    [[- end ]]

    [[- template "task_loki" . ]]
    
    [[- if .loki.minio_enabled ]][[- template "task_minio" . ]]
    [[- end ]]

  } //END group
} // END job