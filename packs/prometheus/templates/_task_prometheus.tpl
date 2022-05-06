/////////////////////////////////////////////////
// TASK prometheus (metrics)
/////////////////////////////////////////////////

[[- define "task_prometheus" ]]

    task "prometheus" {
      driver = "docker"
      leader = true
      
      resources {
        [[- $cpu     := .prometheus.resources.cpu ]]
        [[- $mem     := .prometheus.resources.memory ]]
        [[- $mem_max := .prometheus.resources.memory_max ]]
        cpu = [[ $cpu ]]
        memory = [[ $mem ]]
        [[- if (ge $mem_max $mem) ]]
        memory_max = [[ $mem_max ]][[ end ]]
      }
      
      [[- if $file := .prometheus.config ]]
      
      template {
        change_mode = "restart"
        perms = "444"
        destination = "/local/prometheus.yml"
        data = [[ $file | toJson ]]
      }

      [[- end ]]

      [[- range $file := .prometheus.custom_files ]]
      
      template {
        change_mode = "restart"
        perms = "444"
        destination = [[ $file.destination | toJson ]]
        data = [[ $file.data | toJson ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .prometheus.image | toJson ]]
        args = [[ .prometheus.args | toStringList ]]

        [[- if .prometheus.metrics_prometheus_config ]]

        mount {
          type     = "bind"
          readonly = true
          source   = "local/prometheus.yml"
          target   = "/etc/prometheus/prometheus.yml"
        }
        [[- end ]]

        [[- range $mount := .prometheus.custom_mounts ]]
        
        mount {
          type     = "bind"
          readonly = true
          source   = [[ $mount.source | toJson ]]
          target   = [[ $mount.target | toJson ]]
        }

        [[- end ]]
      }
    }

[[- end ]]