job "[[ template "job_name" . ]]" {
  
  [[- with .my.datacenters ]]
  datacenters = [[ . | toStringList ]]
  [[- end ]]
  
  [[- with .my.namespace ]]
  namespace = [[ . | toStringList ]]
  [[- end ]]
  
  [[- with .my.region ]]
  region = [[ . | toJson ]]
  [[- end ]]

  [[- range $constraint := .my.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    value     = [[ $constraint.value | toJson ]]
    
    [[- if $constraint.operator ]]
    operator  = [[ $constraint.operator | toJson ]][[ end ]]
  }
  [[- end ]]

  group "app" {
    network {
      [[- with .my.network_mode ]]
      mode = [[ . | toJson ]]
      [[- end ]]
      
      [[- range $port := .my.ports ]]
      port [[ $port.label | toJson ]] {
        [[- if gt $port.to 0 ]]
        to = [[ $port.to ]][[ end ]]

        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]][[ end ]]
      }
      [[- end ]]
      
      [[- range $port := .my.connect_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- with .my.ephemeral_disk ]]

    ephemeral_disk {
      migrate = [[ .migrate ]]
      sticky  = [[ .sticky ]]
      size    = [[ .size ]]
    }

    [[- end ]]

    [[- if .my.consul_services ]]
    [[- template "consul_services" . ]][[ end ]]
    
    [[- if .my.consul_services_native ]]
    [[- template "consul_services_native" . ]][[ end ]]

    [[- template "task_traefik" . ]]

    [[- if .my.task_fluentbit_enabled ]]
    [[- template "task_fluentbit" . ]][[ end ]]
  }
}
