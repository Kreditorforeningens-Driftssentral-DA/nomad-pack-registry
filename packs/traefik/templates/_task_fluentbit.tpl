/////////////////////////////////////////////////
// Fluentbit
/////////////////////////////////////////////////

[[- define "task_fluentbit" ]]

    task "fluentbit" {
      driver = "docker"
      
      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      [[- if $res := .my.fluentbit_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory $res.memory_max ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      
      [[- end ]]

      template {
        destination = "${NOMAD_TASK_DIR}/config.yml"
        data = [[ .my.fluentbit_config | toJson ]]
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
        image = [[ .my.fluentbit_image | toJson]]
        command = "/fluent-bit/bin/fluent-bit"
        
        [[- if $args := .my.fluentbit_args ]]
        args = [[ $args | toStringList ]][[ end ]]
        
        [[- if .my.fluentbit_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge ($memory_max := .my.fluentbit_resources.memory_max) .my.traefik_resources.memory ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]
      }
    }
    
[[- end ]]
