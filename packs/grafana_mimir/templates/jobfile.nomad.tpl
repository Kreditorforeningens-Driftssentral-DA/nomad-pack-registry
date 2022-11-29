job "[[ template "job_name" . ]]" {
  datacenters = [[ .my.datacenters | toStringList ]]
  
  [[- if $namespace := .my.namespace ]]
  namespace = [[ $namespace | toJson ]][[ end ]]
  
  [[- if $region := .my.region ]]
  region = [[ $region | toJson ]][[ end ]]

  [[- range $constraint := .my.constraints ]]
  
  constraint {
    attribute = [[ $constraint.attribute | toJson ]]
    operator  = [[ $constraint.operator | toJson ]]
    value     = [[ $constraint.value | toJson ]]
  }

  [[- end ]]

  // Rescheduling disabled
  reschedule {
    attempts  = 0
    unlimited = false
  }

  [[- template "group_nginx" . ]]
  [[- template "group_mimir" . ]]
  
  [[- if .my.minio_enabled ]]
  [[- template "group_minio" . ]][[ end ]]

[[- if .my.memcached_enabled ]]
  [[- template "group_memcached" . ]][[ end ]]

  [[- if .my.grafana_enabled ]]
  [[- template "group_grafana" . ]][[ end ]]
}
