/////////////////////////////////////////////////
// TASK postgres
/////////////////////////////////////////////////

[[- define "task_adminer" ]]

    task "adminer" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      resources {
        cpu = [[ default 50 .activemq.adminer_resources.cpu ]]
        memory = [[ default 32 .activemq.adminer_resources.memory ]]
        memory = [[ default 32 .activemq.adminer_resources.memory_max ]]
      }

      env {
        ADMINER_DEFAULT_SERVER = [[ .activemq.adminer_default_server | toJson ]]
      }

      config {
        image = [[ .activemq.adminer_image | toJson ]]
      }
    }

[[- end ]]
