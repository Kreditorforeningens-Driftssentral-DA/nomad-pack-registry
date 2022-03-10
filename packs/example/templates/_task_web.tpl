/////////////////////////////////////////////////
// Task start (web)
/////////////////////////////////////////////////

[[- define "task_web" ]]

    task "web" {
      driver = "docker"
      
      [[- if .example.resources ]]
      
      resources {
        cpu = [[ .example.resources.cpu ]]
        memory = [[ .example.resources.memory ]]
        memory_max = [[ .example.resources.memory_max ]]
      }

      [[- end ]]

      [[- range $file := .example.files ]]
      
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
        image = [[ .example.image | toJson ]]
        [[- range $mount := .example.mounts ]]
        
        mount {
          type   = "bind"
          source = [[ $mount.source | toJson ]]
          target = [[ $mount.target | toJson ]]
        }

        [[- end ]]
      }
    }

[[- end ]]