job "[[ template "job_name" . ]]" {
  datacenters = [[ .traefik.datacenters | toStringList ]]
  
  [[- if $namespace := .traefik.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .traefik.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .traefik.constraints ]]

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

      [[- range $port := .traefik.ports ]]
      port [[ $port.label | toJson ]] {
        to = [[ $port.to ]]
        
        [[- if gt $port.static 0 ]]
        static = [[ $port.static ]][[ end ]]
      }
      [[- end ]]
      
      [[- range $port := .traefik.connect_exposes ]]
      port [[ $port.port_label | toJson ]] {
        to = -1
      }
      [[- end ]]
    }

    [[- if $disk := .traefik.ephemeral_disk ]]

    ephemeral_disk {
      migrate = [[ $disk.migrate ]]
      sticky = [[ $disk.sticky ]]
      size = [[ $disk.size ]]
    }

    [[- end ]]

    [[- if .traefik.consul_services_native ]]
    [[- template "consul_services_native" . ]]
    [[- else ]]
    [[- if .traefik.consul_services ]]
    [[- template "consul_services" . ]][[ end ]]
    [[- end ]]

    [[- template "task_traefik" . ]]
  }

  [[- if .traefik.group_demo_enabled ]]
  [[- template "group_demo" . ]][[ end ]]
}
