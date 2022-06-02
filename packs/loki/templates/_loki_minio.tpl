/////////////////////////////////////////////////
// TASK minio
/////////////////////////////////////////////////

[[- define "task_minio" ]]

    task "minio" {
      driver = "docker"
      
      lifecycle {
        hook = "prestart"
        sidecar = true
      }
      
      [[- if $res := .my.minio_resources ]]
      
      resources {
        cpu    = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        
        [[- if ge $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }

      [[- end ]]

      [[- if .my.minio_env ]]
      
      env {
        [[- range $k,$v := .my.minio_env ]]
        [[ $k | upper ]] = [[ $v | toJson ]]
        [[- end ]]
      }

      [[- end ]]

      template {
        destination = "/local/docker-startup.sh"
        change_mode = "restart"
        perms = "755"
        data = <<-HEREDOC
        #!/usr/bin/env sh

        if [ "${1}" != "minio" ]; then
          if [ -n "${1}" ]; then
            set -- minio "$@"
          fi
        fi
        
        docker_switch_user() {
          if [ -n "${MINIO_USERNAME}" ] && [ -n "${MINIO_GROUPNAME}" ]; then
            if [ -n "${MINIO_UID}" ] && [ -n "${MINIO_GID}" ]; then
              groupadd -g "${MINIO_GID}" "${MINIO_GROUPNAME}" && \
                useradd -u "${MINIO_UID}" -g "${MINIO_GROUPNAME}" "${MINIO_USERNAME}"
            else
              groupadd "${MINIO_GROUPNAME}" && \
                useradd -g "${MINIO_GROUPNAME}" "${MINIO_USERNAME}"
            fi
            exec setpriv --reuid="${MINIO_USERNAME}" \
              --regid="${MINIO_GROUPNAME}" --keep-groups "$@"
          else
            exec "$@"
          fi
        }
        
        mkdir -p /exports/loki

        if [ -n "${MINIO_USERNAME}" ]; then
          chown ${MINIO_USERNAME}:${MINIO_GROUPNAME} -R /exports
        fi
        
        docker_switch_user "$@"
        HEREDOC
      }

      template {
        destination = "local/buckets/info.txt"
        data = "Contains minio bucket(s)\n"
        change_mode = "noop"
        perms = "444"
      }
      
      config {
        image = [[ .my.minio_image | toJson ]]
        entrypoint = ["/usr/local/bin/docker-startup.sh"]
        args = ["server","/exports","--console-address=:9001"]
        
        [[- if $res := .my.loki_resources ]]

        [[- if $res.cpu_strict ]]
        cpu_hard_limit = true[[ end ]]

        [[- if ge $res.memory_max $res.memory ]]
        memory_hard_limit = [[ $res.memory_max ]][[ end ]]
        
        [[- end ]]
        
        mount {
          type = "bind"
          target = "/usr/local/bin/docker-startup.sh"
          source = "local/docker-startup.sh"
          readonly = false
        }

        mount {
          type = "bind"
          target = "/buckets"
          source = "local/buckets"
          readonly = false
        }
      }
    }

[[- end ]]