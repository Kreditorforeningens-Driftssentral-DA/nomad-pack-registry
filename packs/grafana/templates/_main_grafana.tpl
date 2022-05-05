//////////////////////////////////
// GRAFANA
//////////////////////////////////

[[- define "task_grafana" ]]

    task "grafana" {
      driver = "docker"
      leader = true

      resources {
        cpu = [[ .grafana.resources.cpu ]]
        memory = [[ .grafana.resources.memory ]]
        [[- if gt .grafana.resources.memory_max 0 ]]
        memory_max = [[ .grafana.resources.memory_max ]][[ end ]]
      }

      [[- if .grafana.environment ]]

      env {
        [[- range $k,$v := .grafana.environment ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- range $file := .grafana.files ]]

      template {
        destination = [[ $file.target | toJson ]]
        change_mode = "restart"
        data = [[ $file.content | toJson]]
        perms = "644"
      }

      [[- end ]]

      config {
        image = [[ .grafana.image | toJson ]]

        [[- range $mount := .grafana.mounts ]]

        mount {
          type = [[ $mount.type | toJson]]
          source = [[ $mount.source | toJson]]
          target = [[ $mount.target | toJson]]
        }

        [[- end ]]
      }
    }

[[- end ]]
