[[- define "task_web" ]]

/////////////////////////////////////////////////
// Task start (web)
/////////////////////////////////////////////////

    task "web" {
      driver = "docker"
      
      resources {
        cpu = [[ .bitbucket_runner.resources.cpu ]]
        memory = [[ .bitbucket_runner.resources.memory ]]
        memory_max = [[ .bitbucket_runner.resources.memory_max ]]
      }

      [[- if not (and (.bitbucket_runner.environment|empty) (.bitbucket_runner.settings|empty)) ]]
      
      env {
        [[- range $k,$v := .bitbucket_runner.environment ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      
        [[- range $k,$v := .bitbucket_runner.settings ]]
        [[ $k | upper ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      
      [[- end ]]
      
      [[- range $file := .bitbucket_runner.files ]]

      template {
        change_mode = "restart"
        perms = "644"
        destination = "[[ $file.name ]]"
        [[- if $file.b64encode ]]
        data = "{{ [[ $file.content | b64enc | toJson ]] | base64Decode }}"
        [[- else ]]
        data = [[ $file.content | toJson ]]
        [[- end ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ list .bitbucket_runner.image.name .bitbucket_runner.image.tag | join ":" | print | toJson ]]
        privileged = [[ .bitbucket_runner.privileged ]]

        [[- range $mount := .bitbucket_runner.mounts ]]
        
        mount {
          type   = [[ $mount.bind | toJson ]]
          source = [[ $mount.source | toJson ]]
          target = [[ $mount.target | toJson ]]
          readonly = [[ $mount.readonly ]]
        }

        [[- end ]]
      }
    }

[[- end ]]