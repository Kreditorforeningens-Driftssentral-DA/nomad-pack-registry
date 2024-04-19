/////////////////////////////////////////////////
// TASK fluentbit
/////////////////////////////////////////////////

[[- define "task_fluentbit" ]]

    task "fluentbit" {
      driver = "docker"

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }

      [[- if $res := .activemq.fluentbit_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        [[- if ge $res.memory_max $res.memory]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }

      [[- end ]]

      [[- if not .activemq.fluentbit_credentials | empty ]]

      env {
        [[- range $k,$v := .activemq.fluentbit_credentials ]]
        [[ $k | upper ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      template {
        change_mode = "restart"
        perms = "444"
        destination = "/local/fluentbit.conf"
        data = [[ .activemq.fluentbit_config | toJson ]]
      }

      config {
        image = [[ .activemq.fluentbit_image | toJson ]]
        
        mount {
          type = "bind"
          source = "local/fluentbit.conf"
          target = "/etc/fluentbit/fluentbit.conf"
        }
      }
    }

[[- end ]]
