//////////////////////////////////
// Task (Sidecar) | Scraper
//////////////////////////////////

    [[- define "task_fluentbit" ]]

    task "fluentbit" {
      driver = "docker"
      
      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      resources {
        cpu        = 75
        memory     = 35
        memory_max = 75
      }

      config {
        image      = "fluent/fluent-bit:latest"
        entrypoint = ["/fluent-bit/bin/fluent-bit"]
        args       = ["-c", "/fluent-bit.yaml"]

        mount {
          type     = "bind"
          source   = "local/fluent-bit.yaml"
          target   = "/fluent-bit.yaml"
          readonly = true
        }
      }
      
      template {
        data = <<-HEREDOC
        env:
          log_level: info
          flush_interval: 15
          scrape_interval: 10s
        service:
          daemon: off
          flush: $${flush_interval}
          log_level: $${log_level}
          http_server: off
        pipeline:
          inputs:
          - name: prometheus_scrape
            host: 127.0.0.1
            port: 8080
            metrics_path: /metrics
            tag: mimir.metrics
            scrape_interval: $${scrape_interval}
            mem_buf_limit: 2MB
            storage.type: memory
          outputs:
          - name: prometheus_remote_write
            match: 'mimir.metrics'
            workers: 1
            host: 127.0.0.1
            port: 8081
            uri: /api/v1/push
            header: "X-Scope-OrgID: anonymous"
            add_label:
            - agent fluentbit
            - job {{ env "NOMAD_GROUP_NAME" }}-{{ env "NOMAD_ALLOC_INDEX" }}
        HEREDOC
        destination = "local/fluent-bit.yaml"
        change_mode = "restart"
        perms       = "440"
      }
    }

    [[- end ]]
