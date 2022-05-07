/////////////////////////////////////////////////
// TASK loki
/////////////////////////////////////////////////

[[- define "task_loki" ]]

    task "loki" {
      driver = "docker"
      leader = true

      // Find better solution. Fails if not set (mkdir wal: permission denied)
      user = "root"

      restart {
        interval = "30m"
        attempts = 2
        delay    = "2m"
        mode     = "fail"
      }
      
      [[- if $resources := .loki.loki_resources ]]
      
      resources {
        cpu    = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
        [[- if (ge $resources.memory_max $resources.memory) ]]
        memory_max = [[ $resources.memory_max ]][[ end ]]
      }

      [[- end ]]

      [[- if $file := .loki.loki_config ]]
      
      template {
        destination = "/local/loki.yaml"
        data = [[ $file | toJson]]
        change_mode = "restart"
        perms = "444"
      }

      [[- end ]]
      
      [[- range $file := .loki.loki_custom_files ]]

      template {
        destination = [[ $file.destination | toJson ]]
        data = [[ $file.data | toJson]]
        change_mode = "restart"
        perms = "444"
      }

      [[- end ]]

      config {
        image = [[ .loki.loki_image | toJson ]]
        args = [[ .loki.loki_args | toStringList ]]

        [[- if $mount := .loki.loki_config ]]

        mount {
          type     = "bind"
          readonly = true
          source   = "local/loki.yaml"
          target   = "/loki.yaml"
        }

        [[- end ]]
        
        [[- range $mount := .loki.loki_custom_mounts ]]
        
        mount {
          type     = "bind"
          readonly = true
          source   = [[ $mount.source | toJson ]]
          target   = [[ $mount.target | toJson ]]
        }

        [[- end ]]
      }
    }

[[- end ]]