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
        delay = "2m"
        mode = "fail"
      }
      
      [[- if $res := .my.loki_resources ]]
      
      resources {
        cpu    = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if (ge $res.memory_max $res.memory) ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }

      [[- end ]]

      [[- if $file := .my.loki_config ]]
      
      template {
        destination = "/local/loki.yaml"
        change_mode = "restart"
        perms = "444"
        data = <<-HEREDOC
[[ $file | indent 8 -]]
        HEREDOC
      }
      [[- end ]]
      
      [[- range $file := .my.loki_files ]]
      
      template {
        destination = [[ $file.destination | toJson ]]
        change_mode = "restart"
        perms = "444"
        data = <<-HEREDOC
[[ $file.data | indent 8 -]]
        HEREDOC
      }
      [[- end ]]

      config {
        image = [[ .my.loki_image | toJson ]]
        args = [[ .my.loki_args | toStringList ]]

        [[- if $res := .my.loki_resources ]]
        
        [[- if $res.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge $res.memory_max $res.memory ]]
        memory_hard_limit = [[ $res.memory_max ]][[ end ]]

        [[- end ]]

        [[- if .my.loki_config ]]
        
        mount {
          type     = "bind"
          readonly = true
          source   = "local/loki.yaml"
          target   = "/loki.yaml"
        }
        [[- end ]]
        
        [[- range $mount := .my.loki_mounts ]]
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