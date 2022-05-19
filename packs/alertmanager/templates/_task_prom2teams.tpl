/////////////////////////////////////////////////
// TASK prom2teams (metrics)
/////////////////////////////////////////////////

[[- define "task_prom2teams" ]]

    task "prom2teams" {
      driver = "docker"
      
      lifecycle {
        hook = "prestart"
        sidecar = true
      }
      
      [[- if $res := .alertmanager.prom2teams_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      [[- end ]]

      [[- if $env := .alertmanager.prom2teams_environment ]]
      
      env {
        [[- range $k,$v := $env ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      [[- range $file := .alertmanager.prom2teams_files ]]
      
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
      
      [[- range $file := .alertmanager.prom2teams_files_local ]]

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
        image = [[ .alertmanager.prom2teams_image | toJson ]]
        
        [[- if $args := .alertmanager.prom2teams_args ]]
        args = [[ $args | toStringList ]][[ end ]]

        [[- if $res := .alertmanager.prom2teams_resources ]]
        
        [[- if $res.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if (ge $res.memory_max $res.memory) ]]
        memory_hard_limit = [[ $res.memory_max ]][[ end ]]

        [[- end ]]

        [[- range $mount := .alertmanager.prom2teams_mounts ]]
        
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