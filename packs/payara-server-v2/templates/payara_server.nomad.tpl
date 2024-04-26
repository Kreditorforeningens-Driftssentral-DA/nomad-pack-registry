job [[ template "job_name" . ]] {
  type = "service"
  datacenters = [[ var "datacenters" . | toStringList ]]

  [[- with (var "namespace" .) ]]
  namespace = [[ . | quote ]][[ end ]]

  [[- with (var "region" .) ]]
  region = [[ . ]][[ end ]]
 
  group "payara" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "120s"
      mode     = "fail"
    }

    [[- template "constraint" (var "constraints" .) ]]
    [[- template "service" (var "services" .) ]]

    [[- with $disk := (var "ephemeral_disk" .) ]]

    ephemeral_disk {
      migrate = [[ $disk.migrate ]]
      sticky  = [[ $disk.sticky ]]
      size    = [[ $disk.size ]]
    }

    [[- end ]]

    network {
      mode = [[ var "network_mode" . | quote ]]

      [[- range $port := (var "ports" .)]]
      
      port [[ $port.label | quote ]] {
        to = [[ $port.to ]]
        [[- with $port.static ]]
        static = [[ . ]][[ end ]]
      }
      [[- end ]]
    }

    [[- if (var "service_enabled" .) ]]
    [[ template "service" . ]]
    [[- end ]]

    [[- template "task_payara" . ]]

    [[- if var "fluentbit_enabled" . ]]
    [[ template "task_fluentbit" . ]]
    [[- end ]]
  }
}
