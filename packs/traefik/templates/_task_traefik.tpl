//////////////////////////////////
// traefik
//////////////////////////////////

[[- define "task_traefik" ]]

    task "traefik" {
      driver = "docker"
      leader = true

      [[- if $res := .traefik.traefik_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      [[- end ]]

      [[- if $env := .traefik.traefik_environment ]]

      env {
        [[- range $k,$v := $env ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      [[- range $file := .traefik.traefik_files ]]

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

      [[- range $file := .traefik.traefik_files_local ]]

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
        image = [[ .traefik.traefik_image | toJson ]]
        
        [[- if $args := .traefik.traefik_args ]]
        args = [[ $args | toStringList ]][[ end ]]
        
        [[- if .traefik.traefik_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge ($memory_max := .traefik.traefik_resources.memory_max) .traefik.traefik_resources.memory ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]

        [[- range $mount := .traefik.traefik_mounts ]]

        mount {
          type = "bind"
          source = [[ $mount.source | toJson]]
          target = [[ $mount.target | toJson]]
        }

        [[- end ]]
      }
    }

[[- end ]]
