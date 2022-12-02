//////////////////////////////////
// Group | Proxy
//////////////////////////////////
  
[[- define "group_nginx" ]]
  
  [[- $service_name_mimir := print $.my.mimir_service_prefix $.my.mimir_service_http.postfix ]]
  [[- $service_name       := print $.my.mimir_service_prefix $.my.nginx_service.postfix ]]

  group "mimir-proxy" {
    count = 1
    
    network {
      mode = "bridge"
    }

    [[- if $svc := $.my.nginx_service ]]
    
    service {
      name = [[ $service_name | toJson ]]
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

    [[- end ]]
        
    task "nginx" {
      driver = "docker"
      leader = true

      restart {
        attempts = 3
        delay    = "15s"
        mode     = "fail"
      }
      
      [[- if $res := $.my.nginx_resources ]]

      resources {
        cpu        = [[ $res.cpu ]]
        memory     = [[ $res.memory ]]
        memory_max = [[ $res.memory_max ]]
      }

      [[- end ]]
     
      config {
        image = [[ $.my.nginx_image | toJson ]]
        args  = [[ $.my.nginx_args | toJson ]]

        mount {
          type     = "bind"
          source   = "local/nginx/"
          target   = "/etc/nginx/conf.d"
          readonly = true
        }
      }
      
      env {
        SERVICE_NAME       = [[ $service_name | toJson ]]
        MIMIR_SERVICE_NAME = [[ $service_name_mimir | toJson ]]
      }

      template {
        data = <<-HEREDOC
        upstream mimir-read {
          ip_hash;
          keepalive 5;
          {{- range $svc := connect (env "MIMIR_SERVICE_NAME") }}
            {{- if .Tags | contains "MimirProxyRead" }}
          server {{ .Address }}:{{ .Port }} max_fails=3 fail_timeout=3s;
            {{- end }}
          {{- else }}
          server 127.0.0.1:65535; # force a 502
          {{- end }}
        }

        upstream mimir-write {
          ip_hash;
          keepalive 5;
          {{- range $svc := connect (env "MIMIR_SERVICE_NAME") }}
            {{- if .Tags | contains "MimirProxyWrite" }}
          server {{ .Address }}:{{ .Port }} max_fails=3 fail_timeout=3s;
            {{- end }}
          {{- else }}
          server 127.0.0.1:65535; # force a 502
          {{- end }}
        }
        
        server {
          listen      80;
          access_log  /dev/stdout;
          
          proxy_ssl_verify              off;
          proxy_ssl_certificate         /secrets/cert.pem;
          proxy_ssl_certificate_key     /secrets/key.pem;
          proxy_ssl_trusted_certificate /secrets/ca.pem;

          location = /50x.html {
            root   /usr/share/nginx/html;
          }

          location = /api/v1/push {
            proxy_pass https://mimir-write;
          }

          location / {
            proxy_pass https://mimir-read;
          }
        }

        server {
          listen 8080;
          
          location = /status {
            stub_status;
          }
        }
        HEREDOC
        destination   = "local/nginx/default.conf"
        perms         = "440"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data        = "{{ range caRoots }}{{ .RootCertPEM }}{{ end }}"
        destination = "secrets/ca.pem"
        perms       = "440"
        change_mode = "noop"
      }
      
      template {
        data        = "{{ with caLeaf (env \"SERVICE_NAME\") }}{{ .CertPEM }}{{ end }}"
        destination = "secrets/cert.pem"
        perms       = "440"
        change_mode = "noop"
      }

      template {
        data        = "{{ with caLeaf (env \"SERVICE_NAME\") }}{{ .PrivateKeyPEM }}{{ end }}"
        destination = "secrets/key.pem"
        perms       = "440"
        change_mode = "noop"
      }
    }
    
    [[- if false ]]
    # Todo: Optional metrics: http://127.0.0.1:9113/metrics
    task "nginx-exporter" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      resources {
        cpu        = 50
        memory     = 25
        memory_max = 75
      }

      config {
        image   = "nginx/nginx-prometheus-exporter:latest"
        command = ["-nginx.scrape-uri=http://127.0.0.1:8080/status"]
      }
    }
    [[- end ]]
  }
 
[[- end ]]

