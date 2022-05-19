/////////////////////////////////////////////////
// TASK alertmanager (metrics)
/////////////////////////////////////////////////

[[- define "task_alertmanager" ]]

    task "alertmanager" {
      driver = "docker"
      leader = true
      
      [[- if $res := .alertmanager.alertmanager_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      [[- end ]]

      [[- range $file := .alertmanager.alertmanager_files ]]
      
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
      
      [[- range $file := .alertmanager.alertmanager_files_local ]]

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
        image = [[ .alertmanager.alertmanager_image | toJson ]]
        
        [[- if $args := .alertmanager.alertmanager_args ]]
        args = [[ $args | toStringList ]][[ end ]]

        [[- if .alertmanager.alertmanager_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge ($memory_max := .alertmanager.alertmanager_resources.memory_max) .alertmanager.alertmanager_resources.memory ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]

        [[- range $mount := .alertmanager.alertmanager_mounts ]]
        
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