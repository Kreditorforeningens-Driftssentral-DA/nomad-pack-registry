//////////////////////////////////
// TEMPLATE job_name
//////////////////////////////////

[[- define "job_name" ]]
[[- if .traefik.job_name | empty ]][[ .nomad_pack.pack.name ]]
[[- else -]][[- .traefik.job_name ]]
[[- end ]]
[[- end ]]

