/////////////////////////////////////////////////
// Task maven
/////////////////////////////////////////////////

[[- define "task_maven" ]]

    [[- $entrypoint := "${NOMAD_TASK_DIR}/docker-entrypoint.sh" ]]
    [[- $playbook   := "${NOMAD_TASK_DIR}/playbook.yml" ]]

    task "maven" {
      driver = "docker"
      
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      [[- if $res := .payara_server.maven_resources ]]
      
      resources {
        cpu = [[ $res.cpu ]]
        memory = [[ $res.memory ]]
        [[- if ge $res.memory $res.memory_max ]]
        memory_max = [[ $res.memory_max ]][[ end ]]
      }
      
      [[- end ]]

      // Create inline startup-script
      template {
        destination = [[ $entrypoint | toJson ]]
        perms = "550"
        data = <<-HEREDOC
        #!/usr/bin/env bash
        echo "[$(date)] ansible playbook start."
        . /opt/venv/ansible/bin/activate
        ansible --version
        if [["[["]] -z $(python -m pip list|grep lxml) [["]]"]];then
          python -m pip install lxml
        fi
        if [["[["]] -z $(ansible-galaxy collection list|grep community.general) [["]]"]];then
          ansible-galaxy collection install community.general --upgrade
        fi
        ansible-playbook [[ $playbook ]]
        echo "[$(date)] ansible playbook end."
        HEREDOC
      }

      // Create inline ansible playbook
      template {
        destination = [[ $playbook | toJson ]]
        perms = "440"
        data = <<-HEREDOC
        ---
        - hosts: localhost
          gather_facts: false
          tasks:
          - ansible.builtin.debug:
              msg: "Start of maven download"
          [[- range $artifact := .payara_server.maven_artifacts ]]
          - name: Download Artifact
            community.general.maven_artifact:
              dest: "${NOMAD_ALLOC_DIR}/data/[[ $artifact.name ]].[[ $artifact.extension ]]"
              repository_url: "[[ $.payara_server.maven_auth.server ]]/[[ $artifact.repository ]]"
              username: [[ $.payara_server.maven_auth.username | toJson ]]
              password: [[ $.payara_server.maven_auth.password | toJson ]]
              group_id: [[ $artifact.group | toJson ]]
              artifact_id: [[ $artifact.name | toJson ]]
              extension: [[ $artifact.extension | toJson ]]
              version: [[ $artifact.version | toJson ]]
              mode: 0666
              keep_name: false
              verify_checksum: always
          [[- end ]]
          - ansible.builtin.debug:
              msg: "Finished downloads"
        ...
        HEREDOC
      }
      
      config {
        image = [[ .payara_server.maven_image | toJson]]
        entrypoint = [ [[ $entrypoint | toJson ]] ]

        [[- if .payara_server.maven_cpu_hard_limit ]]
        cpu_hard_limit = true[[ end ]]
      }
    }
    
[[- end ]]