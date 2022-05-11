//////////////////////////////////
// TEMPLATE job_name
//////////////////////////////////

[[- define "job_name" ]]
[[- if .grafana.job_name | empty ]][[ .nomad_pack.pack.name ]]
[[- else -]][[- .grafana.job_name ]]
[[- end ]]
[[- end ]]

