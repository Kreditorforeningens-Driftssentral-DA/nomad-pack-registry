/////////////////////////////////////////////////
// Task start (payara)
/////////////////////////////////////////////////

[[- define "task_payara" ]]

    task "payara" {
      driver = "docker"
      leader = true
      
      [[- if $resources := .payara_server.payara_resources ]]
      
      resources {
        cpu = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
        memory_max = [[ $resources.memory_max ]]
      }

      [[- end ]]

      [[- range $artifact := .payara_server.payara_artifacts ]]
      
      artifact {
        source = [[ $artifact.source | toJson ]]
        destination = [[ $artifact.destination | toJson ]]
        mode = [[ $artifact.mode | toJson ]]
        [[- if not $artifact.options | empty ]]
        options {
          [[- range $k,$v := $artifact.options ]]
          [[ $k ]] = [[ $v | toJson ]]
          [[- end ]]
        }
        [[- end ]]
      }

      [[- end ]]

      [[- if $env := .payara_server.payara_environment_vars ]]
      
      env {
        [[- range $k,$v := $env ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- if $data := .payara_server.payara_environment_file ]]
      
      template {
        change_mode = "restart"
        env = true
        perms = "440"
        destination = "${NOMAD_SECRETS_DIR}/job.env"
        data = [[ $data | toJson ]]
      }

      [[- end ]]

      [[- range $file := .payara_server.payara_custom_files ]]
      
      template {
        change_mode = "restart"
        perms = "444"
        destination = "[[ $file.destination ]]"
        data = [[ $file.data | toJson ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .payara_server.payara_image | toJson ]]
        [[- if .payara_server.payara_cpu_hard_limit ]]
        cpu_hard_limit = true[[ end ]]

        [[- range $mount := .payara_server.payara_custom_mounts ]]
        
        mount {
          type   = "bind"
          source = [[ $mount.source | toJson ]]
          target = [[ $mount.target | toJson ]]
        }
        
        [[- end ]]
      }
    }

[[- end ]]