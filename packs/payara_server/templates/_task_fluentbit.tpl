/////////////////////////////////////////////////
// Task fluentbit
/////////////////////////////////////////////////

[[- define "task_fluentbit" ]]

    task "fluentbit" {
      driver = "docker"
      
      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      [[- if $res := .payara_server.fluentbit_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory $res.memory_max ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      
      [[- end ]]

      template {
        destination = "${NOMAD_TASK_DIR}/config.yml"
        data = [[ .payara_server.fluentbit_config | toJson ]]
        change_mode = "restart"
        perms = "444"
      }

      [[- range $file := .fluentbit_files ]]

      template {
        destination = "${NOMAD_TASK_DIR}/[[ $file.name ]]"
        data = [[ $file.content | toJson ]]
        change_mode = "restart"
        perms = "444"
      }

      [[- end ]]
      
      config {
        image = [[ .payara_server.fluentbit_image | toJson]]
        command = "/fluent-bit/bin/fluent-bit"
        args = ["-c","${NOMAD_TASK_DIR}/config.yml"]

        [[- if .payara_server.fluentbit_cpu_hard_limit ]]
        cpu_hard_limit = true[[ end ]]
      }
    }
    
[[- end ]]
