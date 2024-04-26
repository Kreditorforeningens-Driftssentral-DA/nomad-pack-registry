[[- /*
////////////////////////
// Payara Task (Leader)
////////////////////////
*/ -]]

[[- define "task_payara" ]]

    task "payara" {
      driver = "docker"
      leader = true

      [[- template "resources" (var "payara_resources" .) ]]
      [[- template "env_vars" (var "payara_env" .) ]]

      [[- range $artifact := (var "payara_artifacts" .) ]]
      [[- template "artifact" $artifact ]]
      
      [[- end ]]

      [[- range $file := (var "payara_files" .) ]]
      [[- template "templatefile" $file ]]
      [[- end ]]

      config {
        image = [[ (var "payara_image" .) | toJson ]]
        
        [[- range $file := (var "payara_files" .) ]]
        [[- template "mount" $file ]]
        [[- end ]]
      }
    }

[[- end ]]

[[- /*
////////////////////////
// FluentBit SidecarTask
////////////////////////
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
        
        args = [
          "/fluent-bit/bin/fluent-bit",
          "-c", "/etc/fluentbit/fluentbit.yml",
        ]
        [[- template "mount" (var "fluentbit_config" .) ]]
      }
    }

[[- end ]]
