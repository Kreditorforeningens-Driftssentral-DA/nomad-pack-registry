job "[[ template "job_name" . ]]" {
  datacenters = [[ .grafana.datacenters | toStringList ]]
  
  [[- if $namespace := .grafana.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .grafana.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .grafana.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    value     = [[ $constraint.value | toJson ]]
    
    [[- if $constraint.operator ]]
    operator  = [[ $constraint.operator | toJson ]][[ end ]]
  }

  [[- end ]]

  group "main" {

    network {
      mode = "bridge"

      [[- range $port := .grafana.ports ]]
      port [[ $port.label | toJson ]] {
        to = [[ $port.to ]]
        
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]][[ end ]]
      }
      [[- end ]]
      
      [[- range $port := .grafana.connect_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- if $disk := .grafana.ephemeral_disk ]]

    ephemeral_disk {
      migrate = [[ $disk.migrate ]]
      sticky = [[ $disk.sticky ]]
      size = [[ $disk.size ]]
    }

    [[- end ]]

    [[- if .grafana.consul_services ]]
    [[- template "consul_services" . ]][[ end ]]
    
    [[- template "task_grafana" . ]]
  }
}
