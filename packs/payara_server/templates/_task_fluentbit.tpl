/////////////////////////////////////////////////
// Task fluentbit
/////////////////////////////////////////////////

[[- define "task_fluentbit" ]]

    [[- $entrypoint_file := "${NOMAD_TASK_DIR}/docker-entrypoint.sh" ]]

    task "fluentbit" {
      driver = "docker"
      
      lifecycle {
        hook    = "poststart"
        sidecar = true
      }

      [[- if not .payara_server.fluentbit_resources | empty ]]
      
      resources {
        cpu = [[ .payara_server.fluentbit_resources.cpu ]]
        memory = [[ .payara_server.fluentbit_resources.ram ]]
        memory_max = [[ .payara_server.fluentbit_resources.ram_max ]]
      }
      
      [[- end ]]

      template {
        destination = "${NOMAD_TASK_DIR}/config.conf"
        data = [[ .payara_server.fluentbit_config | toJson ]]
        change_mode = "restart"
        perms = "644"
      }

      [[- range $file := .fluentbit_files ]]

      template {
        destination = "${NOMAD_TASK_DIR}/[[ $file.name ]]"
        data = [[ $file.content | toJson ]]
        change_mode = "restart"
        perms = "644"
      }

      [[- end ]]
      
      config {
        image = [[ .payara_server.fluentbit_image | toJson]]
        command = "/fluent-bit/bin/fluent-bit"
        args = ["-c","${NOMAD_TASK_DIR}/config.conf"]
      }
    }
    
[[- end ]]