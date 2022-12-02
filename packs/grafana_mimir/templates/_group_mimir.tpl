//////////////////////////////////
// Group | Mimir
//////////////////////////////////

[[- define "group_mimir" ]]

  [[- $service_name_http       := print $.my.mimir_service_prefix $.my.mimir_service_http.postfix ]]
  [[- $service_name_memberlist := print $.my.mimir_service_prefix $.my.mimir_service_memberlist.postfix ]]
  [[- $service_name_grpc       := print $.my.mimir_service_prefix $.my.mimir_service_grpc.postfix ]]
  [[- $service_name_proxy      := print $.my.mimir_service_prefix $.my.nginx_service.postfix ]]

  [[- range $group := $.my.mimir_groups ]]

  group [[ $group.name | toJson ]] {
    count = [[ $group.instances ]]
    
    network {
      mode = "bridge"
      
      [[- if $.my.mimir_service_http.exposed ]]
      
      port "http" {
        to = 8080
      }
      
      [[- end ]]

      port "memberlist" {
        to = 7946
      }

      port "grpc" {
        to = 9095
      }
    }

    [[- if $svc := $.my.mimir_service_http ]]
    
    service {
      name = [[ $service_name_http | toJson ]]
      port = [[ $svc.port ]]
      tags = [
        [[- if $group.reader ]]
        "MimirProxyRead",[[ end ]]
        [[- if $group.writer ]]
        "MimirProxyWrite",[[ end ]]
      ]
      
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = [[ $service_name_proxy | toJson ]]
              local_bind_port  = 8081
            }
            [[- range $upstream := $.my.mimir_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | toJson ]]
              local_bind_port  = [[ $upstream.local_port ]]
            }
            [[- end ]]
          }
        }
        sidecar_task {
          resources {
            cpu    = [[ $svc.sidecar_cpu ]]
            memory = [[ $svc.sidecar_memory ]]
          }
        }
      }
    }

    [[- end ]]

    [[- if $svc := $.my.mimir_service_memberlist ]]
   
    service {
      name = [[ $service_name_memberlist | toJson ]]
      port = [[ $svc.port ]]
      
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = [[ $service_name_memberlist | toJson ]]
              local_bind_port  = 7947
            }
          }
        }
        sidecar_task {
          resources {
            cpu    = [[ $svc.sidecar_cpu ]]
            memory = [[ $svc.sidecar_memory ]]
          }
        }
      }
    }

    [[- end ]]

    [[- if $svc := $.my.mimir_service_grpc ]]
    
    service {
      name = [[ $service_name_grpc | toJson ]]
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
    
    [[- if gt (len $.my.mimir_init_script) 0 ]]
    
    task "init" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      resources {
        cpu        = 50
        memory     = 25
        memory_max = 75
      }

      config {
        image = "busybox:latest"
        entrypoint = ["/bin/startup.sh"]

        mount {
          type     = "bind"
          source   = "local/startup.sh"
          target   = "/bin/startup.sh"
          readonly = true
        }
      }

      template {
        data = <<-HEREDOC
[[ $.my.mimir_init_script | indent 8 -]]
        HEREDOC
        perms       = "550"
        destination = "local/startup.sh"
        change_mode = "noop"
      }
    }
    
    [[- end ]]

    task "mimir" {
      driver = "docker"
      leader = true

      restart {
        attempts = 1
        delay    = "15s"
        mode     = "fail"
      }

      [[- if $res := $.my.mimir_resources ]]

      resources {
        cpu        = [[ $res.cpu ]]
        memory     = [[ $res.memory ]]
        memory_max = [[ $res.memory_max ]]
      }

      [[- end ]]

      env {
        [[- if $.my.minio_enabled ]]
        MINIO_ID     = "MinIO"
        MINIO_SECRET = "MinIO@Mimir"
        MINIO_BUCKET = "mimir"
        [[- end ]]
      }

      config {
        image = [[ $.my.mimir_image | toJson ]]
        args  = [[ $group.args | toJson ]]

        mount {
          type     = "bind"
          source   = "local/mimir.yaml"
          target   = "/etc/mimir.yaml"
          readonly = true
        }
      }

      template {
        data = <<-HEREDOC
[[ $.my.mimir_config | indent 8 -]]
        HEREDOC
        perms       = "440"
        destination = "local/mimir.yaml"
        change_mode = "restart"
      }
    }
  
  [[- if $.my.fluentbit_enabled ]]
  [[- template "task_fluentbit" . ]][[ end ]]

  }

  [[- end ]]
[[- end ]]