/////////////////////////////////////////////////
// Task maven
/////////////////////////////////////////////////

[[- define "task_maven" ]]

    [[- $entrypoint_file := "${NOMAD_TASK_DIR}/docker-entrypoint.sh" ]]
    [[- $playbook_file   := "${NOMAD_TASK_DIR}/playbook.yml" ]]

    task "maven" {
      driver = "docker"
      
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      resources {
        cpu = 100
        memory = 128
        memory_max = 384
      }
      
      // Create inline startup-script
      template {
        destination = [[ $entrypoint_file | toJson ]]
        perms = "777"
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
        ansible-playbook [[ $playbook_file ]]
        echo "[$(date)] ansible playbook end."
        HEREDOC
      }

      // Create inline ansible playbook
      template {
        destination = [[ $playbook_file | toJson ]]
        perms = "640"
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
        entrypoint = [ [[ $entrypoint_file | toJson ]] ]
      }
    }
    
[[- end ]]