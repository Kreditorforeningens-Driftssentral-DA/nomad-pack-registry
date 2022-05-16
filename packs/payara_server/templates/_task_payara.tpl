/////////////////////////////////////////////////
// Task start (payara)
/////////////////////////////////////////////////

[[- define "task_payara" ]]

    task "payara" {
      driver = "docker"
      leader = true
      
      [[- if $res := .payara_server.payara_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
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

      [[- if $env := .payara_server.payara_environment ]]
      
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
        destination = "${NOMAD_SECRETS_DIR}/pack.env"
        data = [[ $data | toJson ]]
      }

      [[- end ]]

      [[- range $file := .payara_server.payara_files ]]
      
      template {
        change_mode = "restart"
        perms = "444"
        destination = "[[ $file.destination ]]"
        
        [[- if $file.b64encode ]]
        data = {{ [[ $file.data | toJson ]] | base64Decode }}
        
        [[- else ]]
        data = [[ $file.data | toJson ]][[ end ]]
      }
      
      [[- end ]]

      [[- range $file := .payara_server.payara_files_local ]]
      
      template {
        change_mode = "restart"
        perms = "444"
        destination = "[[ $file.destination ]]"
        
        [[- if $file.b64encode ]]
        data = {{ [[ fileContents $file.filename | b64enc | toJson ]] | base64Decode }}
        
        [[- else ]]
        data = [[ fileContents $file.filename | toJson ]][[ end ]]
      }
      
      [[- end ]]
      
      config {
        image = [[ .payara_server.payara_image | toJson ]]
        
        [[- $res := .payara_server.payara_resources ]]
        
        [[- if $res.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge $res.memory_max $res.memory ]]
        memory_hard_limit = [[ $res.memory_max ]][[ end ]]

        [[- range $mount := .payara_server.payara_mounts ]]
        
        mount {
          type   = "bind"
          source = [[ $mount.source | toJson ]]
          target = [[ $mount.target | toJson ]]
        }
        
        [[- end ]]
      }
    }

[[- end ]]