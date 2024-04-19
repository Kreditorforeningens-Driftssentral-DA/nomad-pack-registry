job "[[ template "job_name" . ]]" {
  datacenters = [[ .activemq.datacenters | toStringList ]]
  
  [[- if $namespace := .activemq.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .activemq.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .activemq.constraints ]]

  constraint {
    [[- if $constraint.attribute ]]
    attribute = [[ $constraint.attribute | toJson ]][[ end ]]
    [[- if $constraint.operator ]]
    operator = [[ $constraint.operator | toJson ]][[ end ]]
    [[- if $constraint.value ]]
    value = [[ $constraint.value | toJson ]][[ end ]]
  }

  [[- end ]]

  group "main" {
    [[- if  $scale := .activemq.scale ]]
    count = [[ $scale ]][[ end ]]

    [[- if $meta := .activemq.meta ]]
    
    meta {
    [[- range $k,$v := $meta ]]
      [[ $k ]] = [[ $v | toJson]]
    [[- end ]]
    }

    [[- end ]]

    [[- if $disk := .activemq.ephemeral_disk ]]
    
    ephemeral_disk {
      migrate = [[ $disk.migrate ]]
      sticky  = [[ $disk.sticky ]]
      size = [[ $disk.size ]]
    }

    [[- end ]]
    
    network {
      mode = "bridge"
      [[- range $port := .activemq.ports ]]
      port [[ $port.label | toJson ]] {
        to = [[ $port.to ]]
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]]
        [[- end ]]
      }
      [[- end ]]
      [[- range $port := .activemq.consul_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- if .activemq.consul_service ]]
    [[- template "consul_service" . ]][[ end ]]

    [[- if .activemq.consul_services ]]
    [[- template "consul_services" . ]][[ end ]]

    [[- if .activemq.task_enabled_postgres ]]
    [[- template "task_postgres" . ]]
    [[- end ]]

    [[- if .activemq.task_enabled_adminer ]]
    [[- template "task_adminer" . ]]
    [[- end ]]

    [[- if .activemq.task_enabled_telegraf ]]
    [[- template "task_telegraf" . ]]
    [[- end ]]

    [[- if .activemq.task_enabled_fluentbit ]]
    [[- template "task_fluentbit" . ]]
    [[- end ]]

    [[- template "task_activemq" . ]]
  }
}