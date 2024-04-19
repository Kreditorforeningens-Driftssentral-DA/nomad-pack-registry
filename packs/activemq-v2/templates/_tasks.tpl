[[- /*
=================================================
 `task_activemq`
=================================================
*/ -]]

[[- define "task_activemq" ]]

    task "activemq" {
      driver = "docker"
      leader = true

      [[- template "resources" (var "activemq_resources" .) ]]
      [[- template "env_vars" (var "activemq_env" .) ]]

      [[- range $file := (var "activemq_files" .) ]]
      [[- template "templatefile" $file ]]
      [[- end ]]

      config {
        image = [[ (var "activemq_image" .) | toJson ]]
        
        [[- range $file := (var "activemq_files" .) ]]
        [[- template "mount" $file ]]
        [[- end ]]
      }
    }

[[- end ]]

[[- /*
=================================================
 `task_telegraf`
=================================================
*/ -]]

[[- define "task_telegraf" ]]

    task "telegraf" {
      driver = "docker"

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }

      [[- template "resources" (var "telegraf_resources" .) ]]
      [[- template "env_vars" (var "telegraf_env" .) ]]
      [[- template "templatefile" (var "telegraf_config" .) ]]

      user = "telegraf" // req. due to "setpriv"

      config {
        image = [[ var "telegraf_image" . | toJson ]]
        
        [[- template "mount" (var "telegraf_config" .) ]]
      }
    }

[[- end ]]

[[- /*
=================================================
 `task_fluentbit`
================================================= 
*/ -]]

[[- define "task_fluentbit" ]]

    task "fluentbit" {
      driver = "docker"

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }

      [[- template "resources" (var "fluentbit_resources" .) ]]
      [[- template "env_vars" (var "fluentbit_env" .) ]]
      [[- template "templatefile" (var "fluentbit_config" .) ]]

      config {
        image = [[ (var "fluentbit_image" .) | toJson ]]
        [[- template "mount" (var "fluentbit_config" .) ]]
      }
    }

[[- end ]]
