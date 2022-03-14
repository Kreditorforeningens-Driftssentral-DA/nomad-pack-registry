[[- define "task_grafana" ]]

/////////////////////////////////////////////////
// TASK grafana (main)
/////////////////////////////////////////////////

    task "grafana" {
      driver = "docker"
      leader = true

      resources {
        cpu    = [[ .grafana.resources.cpu ]]
        memory = [[ .grafana.resources.memory ]]
        memory_max = [[ .grafana.resources.memory_max ]]
      }

      [[- if .grafana.environment ]]

      // Environment
      env {
        [[- range $k,$v := .grafana.environment ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      [[- range $file := .grafana.files ]]

      // Create non-executable files
      template {
        destination = "${NOMAD_TASK_DIR}/[[ $file.name ]]"
        [[- if $file.b64encode ]]
        // Adding variable as base64-encoded string & decoding to disk using consul-template.
        data = "{{ \"[[ $file.content | b64enc ]]\" | base64Decode }}"
        [[- else ]]
        data = [[ $file.content | toJson]]
        [[- end ]]
        change_mode = "restart"
        perms = "644"
      }

      [[- end ]]

      config {
        image = [[ list .grafana.image.name .grafana.image.version | join ":" | toJson ]]
        [[- if gt .grafana.http_port 0 ]]
        ports = ["http"]
        [[- end ]]
      }
    } // Task end

[[- end ]]
