//////////////////////////////////
// Group | MinIO
//////////////////////////////////

[[- define "group_minio" ]]
  
  group "demo-minio" {
    count = 1
    
    network {
      mode = "bridge"

      port "minio-console" {
        to = "9001"
      }
    }

    [[- $svc := $.my.minio_service ]]
    
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
    
    task "minio" {
      driver = "docker"
      leader = true

      restart {
        attempts = 1
        delay    = "15s"
        mode     = "fail"
      }

      resources {
        cpu        = 100
        memory     = 128
        memory_max = 256
      }
      
      env {
        MINIO_ROOT_USER            = "MinIO"
        MINIO_ROOT_PASSWORD        = "Mimir@Min10"
        MINIO_PROMETHEUS_AUTH_TYPE = "public"
        X_MKDIR                    = join("/", ["/alloc/data", "mimir"])
        X_ENTRYPOINT               = "/usr/bin/docker-entrypoint.sh"
        SERVICE_NAME               = [[ $svc.name | toJson ]]
      }

      config {
        image = [[ $.my.minio_image | toJson ]]
        ports      = ["minio-console"]
        entrypoint = ["/usr/bin/prestart.sh"]
        args       = [
          "server",
          "/alloc/data",
          "--console-address",":9001",
        ]
        
        mount {
          type     = "bind"
          source   = "local/prestart.sh"
          target   = "/usr/bin/prestart.sh"
          readonly = true
        }
      }

      template {
        data = <<-HEREDOC
        #!/bin/bash
        mkdir -p {{ env "X_MKDIR" }}
        exec {{ env "X_ENTRYPOINT" }} $@
        HEREDOC
        destination   = "local/prestart.sh"
        perms         = "550"
        change_mode   = "noop"
      }
    }
  }
  
[[- end ]]
