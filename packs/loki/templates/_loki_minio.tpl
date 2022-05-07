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
      
      [[- if not .loki.minio_resources | empty ]]
      
      resources {
        cpu    = [[ .loki.minio_resources.cpu ]]
        memory = [[ .loki.minio_resources.memory ]]
        memory_max = [[ .loki.minio_resources.memory_max ]]
      }
      [[- end ]]

      [[- if not .loki.minio_env | empty ]]
      
      env {
        [[- range $k,$v := .loki.minio_env ]]
        [[ $k ]] = [[ $v | toJson ]]
        [[- end ]]
      }
      [[- end ]]

      template {
        destination = "/local/docker-custom.sh"
        data = <<-EOH
        #!/bin/sh
        # If command starts with an option, prepend minio.
        if [ "${1}" != "minio" ]; then
          if [ -n "${1}" ]; then
            set -- minio "$@"
          fi
        fi
        # su-exec to requested user, if service cannot run exec will fail.
        docker_switch_user() {
          if [ -n "${MINIO_USERNAME}" ] && [ -n "${MINIO_GROUPNAME}" ]; then
            if [ -n "${MINIO_UID}" ] && [ -n "${MINIO_GID}" ]; then
              groupadd -g "$MINIO_GID" "$MINIO_GROUPNAME" && \
                useradd -u "$MINIO_UID" -g "$MINIO_GROUPNAME" "$MINIO_USERNAME"
            else
              groupadd "$MINIO_GROUPNAME" && \
                useradd -g "$MINIO_GROUPNAME" "$MINIO_USERNAME"
            fi
            exec setpriv --reuid="${MINIO_USERNAME}" \
              --regid="${MINIO_GROUPNAME}" --keep-groups "$@"
          else
            exec "$@"
          fi
        }
        ## Switch to user if applicable.
        # Customize: Add bucket
        mkdir -p /exports/loki
        chown $MINIO_USERNAME:$MINIO_GROUPNAME -R /exports
        docker_switch_user "$@"
        EOH
        change_mode = "restart"
        perms = "755"
      }

      template {
        destination = "local/buckets/info.txt"
        data = "Contains minio bucket(s)\n"
        change_mode = "noop"
        perms = "666"
      }
      
      config {
        image = [[ list .loki.minio_image.name .loki.minio_image.version | join ":" | toJson ]]
        entrypoint = ["/usr/bin/docker-custom.sh"]
        args = ["server","/exports","--console-address=:9001"]
        
        mount {
          type = "bind"
          target = "/usr/bin/docker-custom.sh"
          source = "local/docker-custom.sh"
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