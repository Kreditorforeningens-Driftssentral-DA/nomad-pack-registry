//////////////////////////////////
// Group | Grafana
//////////////////////////////////
  
[[- define "group_grafana" ]]
  
  [[- $service_name_mimir := print $.my.mimir_service_prefix $.my.nginx_service.postfix ]]
  
  group "demo-grafana" {
    count = 1
    
    network {
      mode = "bridge"
      
      port "grafana-console" {
        to = 3000
      }
    }

    [[- $svc := $.my.grafana_service ]]
    
    service {
      name = [[ $svc.name | toJson ]]
      port = [[ $svc.port ]]
      
      connect {
        sidecar_service {}
        sidecar_task {
          resources {
            cpu    = [[ $svc.sidecar_cpu ]]
            memory = [[ $svc.sidecar_memory ]]
          }
        }
      }
    }
        
    task "grafana" {
      driver = "docker"
      leader = true

      restart {
        attempts = 1
        delay    = "15s"
        mode     = "fail"
      }

      resources {
        cpu        = 100
        memory     = 96
        memory_max = 256
      }

      config {
        image = "grafana/grafana:latest"

        mount {
          type     = "bind"
          source   = "local/provisioning"
          target   = "/etc/grafana/provisioning"
          readonly = true
        }
        
        /*mount {
          type     = "bind"
          source   = "local/dashboards"
          target   = "/var/lib/grafana/dashboards"
          readonly = true
        }*/
      }
      
      env {
        GF_AUTH_ANONYMOUS_ENABLED  = "true"
        GF_AUTH_DISABLE_LOGIN_FORM = "true"
        GF_AUTH_ANONYMOUS_ORG_ROLE = "Admin"
        GF_LOG_MODE                = "console"
        GF_LOG_LEVEL               = "critical"
        GF_USERS_DEFAULT_THEME     = "dark"
        GF_PATHS_PROVISIONING      = "/etc/grafana/provisioning"
        GF_DEFAULT_TIMEZONE        = "Europe/Oslo"
        GF_INSTALL_PLUGINS         = "grafana-clock-panel"
      }

      template {
        data = <<-HEREDOC
        apiVersion: 1
        datasources:
        -
          name: Metrics (Mimir)
          type: prometheus
          access: proxy
          url: http://127.0.0.1:8080/prometheus
          version: 1
          editable: false
          isDefault: true
          jsonData:
            prometheusType: Mimir
        HEREDOC
        destination   = "local/provisioning/datasources/provisioned.yaml"
        perms         = "440"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      /*template {
        data = <<-HEREDOC
        HEREDOC
        destination   = "local/provisioning/dashboards/dashboards.yaml"
        perms         = "440"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }*/
    }
  }
 
[[- end ]]

