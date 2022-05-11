job "[[ template "job_name" . ]]" {
  datacenters = [[ $datacenters := .my.datacenters | toStringList ]]
  
  [[- if $namespace := .my.namespace ]]
  region = [[ $namespace | toJson ]][[ end ]]

  [[- if $region := .my.region ]]
  region = [[ $region | toJson ]][[ end ]]

  group "main" {
    
    network {
      mode = "bridge"
      
      [[- range $port := .my.ports ]]
      port [[ $port.label | toJson ]] {
        [[- if $port.to ]]
        to = [[ $port.to ]][[ end ]]
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]][[ end ]]
      }
      [[- end ]]
      
      [[- range $port := .my.consul_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- if $consul_service := .my.consul_service ]]
    [[- template "consul_service" . ]][[ end ]]
    
    [[- template "task_nginx" . ]]
  }
}