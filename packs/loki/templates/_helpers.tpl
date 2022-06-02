/////////////////////////////////////////////////
// TEMPALTE job_name
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- if not .my.job_name ]][[ .nomad_pack.pack.name ]]
[[- else ]][[ .my.job_name ]]
[[- end ]][[ end ]]
