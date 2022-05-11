/////////////////////////////////////////////////
// TASK nginx
/////////////////////////////////////////////////

[[- define "task_nginx" ]]

    task "nginx" {
      driver = "docker"
      leader = true
      
      [[- if $resources := .my.nginx_resources ]]
      
      resources {
        cpu = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
        [[- if gt $resources.memory_max 0 ]]
        memory_max = [[ $resources.memory_max ]][[ end ]]
      }
      [[- end ]]
      
      config {
        image = [[ .my.nginx_image | toJson ]]
        [[- if gt ($memory_max := .my.nginx_resources.memory_max) 0 ]]
        memory_hard_limit = [[ $memory_max ]][[ end ]]
        [[- if $cpu_strict := .my.nginx_resources.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]
      }
    }

[[- end ]]