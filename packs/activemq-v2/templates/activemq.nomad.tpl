job [[ template "job_name" . ]] {
  [[- with (var "region" .) ]]
  region      = [[ . ]][[ end ]]
  [[- with (var "namespace" .) ]]
  namespace   = [[ . ]][[ end ]]
  type        = "service"
  datacenters = [[ var "datacenters" . | toStringList ]]

  group "app" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "120s"
      mode     = "fail"
    }

    [[- template "constraint" (var "constraints" .) ]]
    [[- template "service" (var "services" .) ]]

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

    [[- template "task_activemq" . ]]

    [[- if var "telegraf_enabled" . ]]
    [[ template "task_telegraf" . ]]
    [[- end ]]

    [[- if var "fluentbit_enabled" . ]]
    [[ template "task_fluentbit" . ]]
    [[- end ]]
  }
}
