[[- define "task_fluentbit" ]]

/////////////////////////////////////////////////
// TASK fluentbit (main)
/////////////////////////////////////////////////

    task "fluentbit" {
      driver = "docker"
      
      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      [[- if not .grafana.fluentbit_resources | empty ]]
      
      resources {
        cpu    = [[ .grafana.fluentbit_resources.cpu ]]
        memory = [[ .grafana.fluentbit_resources.memory ]]
        memory_max = [[ .grafana.fluentbit_resources.memory_max ]]
      }
      [[- end ]]
      
      [[- range $file := .grafana.fluentbit_files ]]

      // Create non-executable files
      template {
        destination = "${NOMAD_TASK_DIR}/[[ $file.name ]]"
        [[- if $file.b64encode ]]
        data = "{{ \"[[ $file.content | b64enc ]]\" | base64Decode }}"
        [[- else ]]
        data = [[ $file.content | toJson]]
        [[- end ]]
        change_mode = "restart"
        perms = "644"
      }

      [[- end ]]

      config {
        image = [[ list .grafana.fluentbit_image.name .grafana.fluentbit_image.version | join ":" | toJson ]]
        command = "/fluent-bit/bin/fluent-bit"
        args = [[ .grafana.fluentbit_args | toJson ]]
      }
    }

[[- end ]]