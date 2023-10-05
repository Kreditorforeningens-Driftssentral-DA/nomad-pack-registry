//////////////////////////////////
// TEMPLATE job_name
//////////////////////////////////

[[- define "job_name" ]]
[[- if .my.job_name | empty ]][[ .nomad_pack.pack.name ]]
[[- else -]][[- .my.job_name ]]
[[- end ]]
[[- end ]]

