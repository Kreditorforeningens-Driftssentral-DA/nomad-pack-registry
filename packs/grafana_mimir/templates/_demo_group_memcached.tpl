//////////////////////////////////
// Group | Memcached
//////////////////////////////////
  
[[- define "group_memcached" ]]
  
  group "demo-memcached" {
    count = 1
    
    network {
      mode = "bridge"
    }

    [[- $svc := $.my.memcached_service ]]
    
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
        
    task "memcached" {
      driver = "docker"
      leader = true

      restart {
        attempts = 1
        delay    = "15s"
        mode     = "fail"
      }

      resources {
        cpu        = 50
        memory     = 64
        memory_max = 128
      }

      config {
        image   = [[ $.my.memcached_image | toJson ]]
        command = [
          "-m 128",
          "-t 2",
          "-vv"
        ]
      }
    }
  }
 
[[- end ]]

