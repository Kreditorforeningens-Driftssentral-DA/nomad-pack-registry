/////////////////////////////////////////////////
// Task start (payara)
/////////////////////////////////////////////////

[[- define "task_payara" ]]

    task "payara" {
      driver = "docker"
      
      [[- if .payara_server.resources ]]
      
      resources {
        cpu = [[ .payara_server.resources.cpu ]]
        memory = [[ .payara_server.resources.memory ]]
        memory_max = [[ .payara_server.resources.memory_max ]]
      }

      [[- end ]]

      [[- if not .payara_server.environment_variables | empty ]]
      
      env {
        [[- range $k,$v := .payara_server.environment_variables ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- if not .payara_server.environment_file | empty ]]
      
      template {
        change_mode = "restart"
        env = true
        perms = "440"
        destination = "${NOMAD_SECRETS_DIR}/job.env"
        data = [[ .payara_server.environment_file | toJson ]]
      }

      [[- end ]]

      [[- range $file := .payara_server.files ]]
      
      template {
        change_mode = "restart"
        perms = "644"
        destination = "[[ $file.filename ]]"
        data = [[ $file.content | toJson ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .payara_server.image | toJson ]]
        
        [[- range $file := .payara_server.files ]][[ if not $file.mount | empty ]]
        
        mount {
          type   = "bind"
          source = [[ $file.filename | toJson ]]
          target = [[ $file.mount | toJson ]]
        }
        
        [[- end ]][[ end ]]
      }
    }

[[- end ]]