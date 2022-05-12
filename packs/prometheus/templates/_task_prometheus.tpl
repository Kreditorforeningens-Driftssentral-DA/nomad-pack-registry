/////////////////////////////////////////////////
// TASK prometheus (metrics)
/////////////////////////////////////////////////

[[- define "task_prometheus" ]]

    task "prometheus" {
      driver = "docker"
      leader = true
      
      [[- if $res := .prometheus.prometheus_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      [[- end ]]

      [[- range $file := .prometheus.prometheus_files ]]
      
      template {
        destination = [[ $file.destination | toJson ]]
        change_mode = "restart"
        [[- if $file.b64encode ]]
        data = {{ [[ $file.data | b64enc | toJson ]] | base64Decode }}
        [[- else ]]
        data = [[ $file.data | toJson]]
        [[- end ]]
        perms = "444"
      }
      
      [[- end ]]
      
      [[- range $file := .prometheus.prometheus_files_local ]]

      template {
        destination = [[ $file.destination | toJson ]]
        change_mode = "restart"
        perms = "444"
        [[- if $file.b64encode ]]
        data = {{ [[ fileContents $file.filename | b64enc | toJson ]] | base64Decode }}
        [[- else ]]
        data = [[ fileContents $file.filename | toJson ]][[ end ]]
      }

      [[- end ]]

      config {
        image = [[ .prometheus.prometheus_image | toJson ]]
        
        [[- if $args := .prometheus.prometheus_args ]]
        args = [[ $args | toStringList ]][[ end ]]

        [[- if .prometheus.prometheus_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge ($memory_max := .prometheus.prometheus_resources.memory_max) .prometheus.prometheus_resources.memory ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]

        [[- range $mount := .prometheus.prometheus_mounts ]]
        
        mount {
          type     = "bind"
          source   = [[ $mount.source | toJson ]]
          target   = [[ $mount.target | toJson ]]
          readonly = true
        }

        [[- end ]]
      }
    }

[[- end ]]