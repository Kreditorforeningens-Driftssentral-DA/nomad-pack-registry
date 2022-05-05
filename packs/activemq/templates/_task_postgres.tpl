/////////////////////////////////////////////////
// TASK postgres
/////////////////////////////////////////////////

[[- define "task_postgres" ]]

    task "db-wait" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      restart {
        interval = "1m"
        attempts = 5
        delay = "10s"
        mode = "fail"
      }

      resources {
        cpu = 50
        memory = 64
      }

      [[- if not .activemq.postgres_environment | empty ]]

      env {
        [[- range $k,$v := .activemq.postgres_environment ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      config {
        image = [[ .activemq.postgres_image | toJson ]]
        command = "/usr/bin/pg_isready"
        args = [
          "-h","localhost",
          "-p","5432",
          "-t","5",
          "-U","${POSTGRES_USER}",
        ]
      }
    }
    
    task "postgres" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = true
      }
      
      [[- if .activemq.postgres_resources ]]
      
      resources {
        cpu = [[ default 100 .activemq.postgres_resources.cpu ]]
        memory = [[ default 128 .activemq.postgres_resources.memory ]]
        memory_max = [[ default 128 .activemq.postgres_resources.memory_max ]]
      }

      [[- end ]]

      [[- if not .activemq.postgres_environment | empty ]]

      env {
        [[- range $k,$v := .activemq.postgres_environment ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- range $file := .activemq.postgres_files ]]
      
      template {
        change_mode = "restart"
        perms = "644"
        destination = "[[ $file.name ]]"
        data = [[ $file.content | toJson ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .activemq.postgres_image | toJson ]]
      }
    }

[[- end ]]
