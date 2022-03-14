[[- define "task_fluentbit" ]]

/////////////////////////////////////////////////
// TASK fluentbit
/////////////////////////////////////////////////

    task "fluentbit" {
      driver = "docker"
      leader = true
      
      [[- if not .fluentbit.resources | empty ]]
      
      resources {
        cpu    = [[ .fluentbit.resources.cpu ]]
        memory = [[ .fluentbit.resources.memory ]]
        memory_max = [[ .fluentbit.resources.memory_max ]]
      }
      [[- end ]]
      
      [[- range $file := .fluentbit.files ]]

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
        image = [[ list .fluentbit.image.name .fluentbit.image.version | join ":" | toJson ]]
        command = "/fluent-bit/bin/fluent-bit"
        args = [[ .fluentbit.fluentbit_args | toJson ]]
      }
    }

[[- end ]]