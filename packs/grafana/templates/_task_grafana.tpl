//////////////////////////////////
// GRAFANA
//////////////////////////////////

[[- define "task_grafana" ]]

    task "grafana" {
      driver = "docker"
      leader = true

      [[- if $res := .grafana.grafana_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      [[- end ]]

      [[- if $env := .grafana.grafana_environment ]]

      env {
        [[- range $k,$v := $env ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      [[- range $file := .grafana.grafana_files ]]

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

      [[- range $file := .grafana.grafana_files_local ]]

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
        image = [[ .grafana.grafana_image | toJson ]]
        
        [[- if .grafana.grafana_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge ($memory_max := .grafana.grafana_resources.memory_max) .grafana.grafana_resources.memory ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]

        [[- range $mount := .grafana.grafana_mounts ]]

        mount {
          type = "bind"
          source = [[ $mount.source | toJson]]
          target = [[ $mount.target | toJson]]
        }

        [[- end ]]
      }
    }

[[- end ]]
