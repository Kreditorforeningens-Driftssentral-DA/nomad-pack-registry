//////////////////////////////////
// demo
//////////////////////////////////

[[- define "group_demo" ]]
  
  group "demo" {
    count = 2

    network {
      mode = "bridge"
    }

    service {
      port = "5055"
      name = "traefik-v2-demo"

      tags = [
        "traefik-v2.enable=true",
        "traefik-v2.http.routers.TraefikDemo.entrypoints=http"
      ]

      connect {
        sidecar_service {}
        sidecar_task {
          resources {
            cpu = 50
            memory = 50
          }
        }
      }
    }

    task "demo" {
      driver = "docker"

      resources {
        cpu = 25
        memory = 50
      }

      config {
        image = "traefik/whoami:latest"
        args = ["--port","5055"]
      }
    }
  }
[[- end ]]
