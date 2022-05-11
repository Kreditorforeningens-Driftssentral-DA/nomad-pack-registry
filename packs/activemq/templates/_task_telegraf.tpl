/////////////////////////////////////////////////
// TASK telegraf
/////////////////////////////////////////////////

[[- define "task_telegraf" ]]

    task "telegraf" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      [[- if $res := .activemq.telegraf_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        [[- if ge $res.memory_max $res.memory]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }

      [[- end ]]

      [[- if not .activemq.telegraf_credentials | empty ]]

      env {
        [[- range $k,$v := .activemq.telegraf_credentials ]]
        [[ $k | upper ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      template {
        change_mode = "restart"
        perms = "444"
        destination = "/local/telegraf.conf"
        data = [[ .activemq.telegraf_config | toJson ]]
      }

      user = "telegraf" // req. due to setpriv

      config {
        image = [[ .activemq.telegraf_image | toJson ]]
        
        mount {
          type = "bind"
          source = "local/telegraf.conf"
          target = "/etc/telegraf/telegraf.conf"
        }
      }
    }

[[- end ]]
