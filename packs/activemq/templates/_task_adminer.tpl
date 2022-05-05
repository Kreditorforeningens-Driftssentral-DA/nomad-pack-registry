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
        cpu = 100
        memory = 32
      }

      env {
        ADMINER_DEFAULT_SERVER = [[ .activemq.adminer_default_server | toJson ]]
      }

      config {
        image = [[ .activemq.adminer_image | toJson ]]
      }
    }

[[- end ]]
