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

  group "prometheus" {
    count = [[ .prometheus.instances ]]

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
      port [[ $port.name | toJson ]] {
        to = [[ $port.to ]]
        [[- if (gt $port.static 0) ]]
        static = [[ $port.static ]][[- end ]]
      }
      [[- end ]]
    }

    [[- if ($service := .prometheus.consul_service) ]]

    service {
      [[- if $service.name ]]
      name = [[ $service.name | toJson ]][[ end ]]
      port = [[ $service.port | toJson ]]
      tags = [[ $service.tags | toStringList ]]
      
      [[- if ($meta := $service.meta) ]]
      meta {
        [[- range $k,$v := $meta ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]
      connect {
        [[- if (or (gt $service.sidecar_cpu 0) (gt $service.sidecar_memory 0)) ]]
        sidecar_task {
          resources {
            cpu = 100
            memory = 32
          }
        }
        [[- end ]]
        sidecar_service {}
      }
      check {
        name     = "alive"
        type     = "http"
        port     = [[ $service.port | toJson ]]
        path     = "/-/healthy"
        interval = "15s"
        timeout  = "5s"
        [[- if $service.expose_check]]
        expose   = true
        [[- end ]]
      }
    }

    [[- end ]]

    [[- template "task_prometheus" . ]]
  }
}
