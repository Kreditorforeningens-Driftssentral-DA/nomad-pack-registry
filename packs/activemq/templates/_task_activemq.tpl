/////////////////////////////////////////////////
// TASK - ActiveMQ
/////////////////////////////////////////////////

[[- define "task_activemq" ]]

    task "activemq" {
      driver = "docker"
      
      [[- if .activemq.resources ]]
      
      resources {
        cpu = [[ default 100 .activemq.resources.cpu ]]
        memory = [[ default 384 .activemq.resources.memory ]]
        memory_max = [[ default 384 .activemq.resources.memory_max ]]
      }

      [[- end ]]

      [[- if not .activemq.environment | empty ]]

      env {
        [[- range $k,$v := .activemq.environment ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- range $file := .activemq.files ]]
      
      template {
        change_mode = "restart"
        perms = "644"
        destination = "[[ $file.name ]]"
        data = [[ $file.content | toJson ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .activemq.image | toJson ]]
        [[- range $mount := .activemq.mounts ]]
        
        mount {
          type   = "bind"
          source = [[ $mount.source | toJson ]]
          target = [[ $mount.target | toJson ]]
        }

        [[- end ]]
      }
    }

[[- end ]]
