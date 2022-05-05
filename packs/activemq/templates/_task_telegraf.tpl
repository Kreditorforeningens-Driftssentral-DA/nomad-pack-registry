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

      resources {
        cpu = 50
        memory = 64
      }

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
