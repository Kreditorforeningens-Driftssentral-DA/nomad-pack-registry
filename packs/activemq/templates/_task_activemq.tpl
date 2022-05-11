/////////////////////////////////////////////////
// TASK - ActiveMQ
/////////////////////////////////////////////////

[[- define "task_activemq" ]]

    task "activemq" {
      driver = "docker"
      leader = true
      
      [[- if $resources := .activemq.activemq_resources ]]
      
      resources {
        cpu = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
        [[- if ge $resources.memory_max $resources.memory ]]
        memory_max = [[ $resources.memory_max ]][[ end ]]
      }

      [[- end ]]

      [[- if $env := .activemq.activemq_environment ]]

      env {
        [[- range $k,$v := $env ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- range $file := .activemq.activemq_custom_files ]]
      
      template {
        change_mode = "restart"
        perms = "444"
        destination = "[[ $file.name ]]"
        data = [[ $file.data | toJson ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .activemq.activemq_image | toJson ]]
        [[- if $pull := .activemq.activemq_image_pull  ]]
        force_pull = true[[ end ]]
        
        [[- if gt ($memory_max := .activemq.activemq_resources.memory_max) 0 ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]
        
        [[- if $cpu_strict := .activemq.activemq_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- range $mount := .activemq.activemq_custom_mounts ]]
        
        mount {
          type = "bind"
          source = [[ $mount.source | toJson ]]
          target = [[ $mount.target | toJson ]]
        }

        [[- end ]]
      }
    }

[[- end ]]
