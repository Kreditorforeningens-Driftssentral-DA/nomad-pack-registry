[[/*
  Description of the template here ..
*/]]

/////////////////////////////////////////////////
// Job
/////////////////////////////////////////////////

job "[[ template "job_name" . ]]" {

  type = "service"
  namespace = [[ .grafana.namespace | quote ]]
  region = [[ .grafana.region | quote ]]
  priority = [[ .grafana.priority ]]
  
  [[- template "datacenters" . ]]

  [[- if .grafana.constraints ]][[ range $idx, $constraint := .grafana.constraints ]]

  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]

    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }

  [[- end ]][[- end ]]

/////////////////////////////////////////////////
// Group (main)
/////////////////////////////////////////////////

  group "main" {
    count = [[ .grafana.instances ]]

    network {
      mode = "bridge"
      [[- if .grafana.expose_envoy_metrics ]]
      port "envoy_metrics_http" {
        to = 9102
      }
      [[- end ]]
      
      [[- if gt .grafana.http_port 0 ]]
      port "http"{
        to = [[ .grafana.http_port ]]
      }
      [[ end ]]
    }

    [[- if not .grafana.ephemeral_disk | empty ]]

    ephemeral_disk {
      migrate = [[ .grafana.ephemeral_disk.migrate ]]
      sticky = [[ .grafana.ephemeral_disk.sticky ]]
      size = [[ .grafana.ephemeral_disk.size ]]
    }
    [[- end ]]

    [[- range $svc := .grafana.consul_services ]]

/////////////////////////////////////////////////
// Consul Services (main)
/////////////////////////////////////////////////
 
    service {
      name = [[ $svc.name | toJson ]]
      port = [[ $svc.port ]]
      tags = [[ $svc.tags | toJson ]]
      
      [[- if $.grafana.expose_envoy_metrics ]]

      meta {
        metrics_port_prometheus = "${NOMAD_HOST_PORT_envoy_metrics_http}"
      }
      
      [[- end ]]
      
      connect {
        sidecar_task {
          resources {
            cpu    = [[ $svc.cpu ]]
            memory = [[ $svc.memory ]]
          }
        }

        sidecar_service {
          proxy {
            
            [[- if $.grafana.expose_envoy_metrics ]]
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
            [[- end ]]

            [[- range $idx,$target := $svc.upstreams ]]
            upstreams {
              destination_name = [[ $target | toJson ]]
              local_bind_port  = [[ add $svc.upstream_first_port $idx ]]
            }
            [[- end ]]
          }
        }
      }
    } // service end

    [[- end ]]

    [[- template "task_grafana" . ]]

    [[- if .grafana.fluentbit_enabled ]]
    [[- template "task_fluentbit" . ]][[ end ]]

  } // Group end (main)
} // Job end
