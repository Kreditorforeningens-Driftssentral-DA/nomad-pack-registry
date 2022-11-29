//////////////////////////////////
// Task | Bitbucket Runner
//////////////////////////////////

[[- define "task_runner" ]]

    task "runner" {
      driver = "docker"
      leader = true
      
      [[- if $res := .my.resources ]]
      
      resources {
        cpu        = [[ $res.cpu ]]
        memory     = [[ $res.memory ]]
        memory_max = [[ $res.memory_max ]]
      }
      [[- end ]]

      [[- if not (and (.my.environment|empty) (.my.settings|empty)) ]]
      
      env {
        [[- range $key,$value := .my.environment ]]
        [[ $key ]] = [[ $value | toJson ]]
        [[- end ]]
      
        [[- range $key,$value := .my.settings ]]
        [[ $key | upper ]] = [[ $value | toJson ]]
        [[- end ]]
      }
      
      [[- end ]]
      
      [[- range $file := .my.files ]]

      template {
        [[- if $file.b64encode ]]
        data = "{{ [[ $file.content | b64enc | toJson ]] | base64Decode }}"
        [[- else ]]
        data = [[ $file.content | toJson ]]
        [[- end ]]
        change_mode = "restart"
        perms = "644"
        destination = "[[ $file.name ]]"
      }
      
      [[- end ]]
      
      config {
        image = [[ list .my.image.name .my.image.tag | join ":" | print | toJson ]]
        privileged = [[ .my.privileged ]]

        [[- range $mount := .my.mounts ]]
        
        mount {
          type     = [[ $mount.type | toJson ]]
          source   = [[ $mount.source | toJson ]]
          target   = [[ $mount.target | toJson ]]
          readonly = [[ $mount.readonly ]]
        }

        [[- end ]]
      }
    }

[[- end ]]