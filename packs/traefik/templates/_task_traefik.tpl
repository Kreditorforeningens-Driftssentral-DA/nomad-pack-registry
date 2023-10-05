//////////////////////////////////
// Traefik
//////////////////////////////////

[[- define "task_traefik" ]]

    task "traefik" {
      driver = "docker"
      leader = true

      [[- with .my.traefik_resources ]]
      
      resources {
        cpu = [[ .cpu ]]
        memory = [[ .memory ]]
        
        [[- if ge .memory_max .memory ]]
        memory_max = [[ .memory_max ]][[ end ]]
      }
      [[- end ]]

      [[- with .my.traefik_environment ]]

      env {
        [[- range $k,$v := . ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      [[- range $file := .my.traefik_files ]]

      template {
        destination = [[ $file.destination | toJson ]]
        change_mode = "restart"
        perms = "444"
        [[- if $file.b64encode ]]
        data = "{{ \"[[ $file.data | b64enc ]]\" | base64Decode }}"
        [[- else ]]
        data = <<-HEREDOC
        [[- $file.data | nindent 8 -]]
        HEREDOC
        [[- end ]]
      }
      [[- end ]]

      [[- range $file := .my.traefik_files_local ]]

      template {
        destination = [[ $file.destination | toJson ]]
        change_mode = "restart"
        perms = "444"
        [[- if $file.b64encode ]]
        data = "{{ \"[[ fileContents $file.filename | b64enc ]]\" | base64Decode }}"
        [[- else ]]
        data = [[ fileContents $file.filename | toJson ]][[ end ]]
      }
      [[- end ]]      

      config {
        image = [[ .my.traefik_image | toJson ]]

        [[- if (ne .my.network_mode "bridge") ]]
        network_mode = [[ .my.network_mode | toJson ]]
        [[- end ]]

        [[- with $.my.ports ]]
        ports = [
        [[- range $_,$v := . ]]
          [[ $v.label | toJson ]],
        [[- end ]]
        ]
        [[- end ]]

        [[- if $args := .my.traefik_args ]]
        args = [[ $args | toStringList ]][[ end ]]
        
        [[- if .my.traefik_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge ($memory_max := .my.traefik_resources.memory_max) .my.traefik_resources.memory ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]

        [[- range $mount := .my.traefik_mounts ]]

        mount {
          type = "bind"
          source = [[ $mount.source | toJson]]
          target = [[ $mount.target | toJson]]
        }

        [[- end ]]
      }
    }

[[- end ]]
