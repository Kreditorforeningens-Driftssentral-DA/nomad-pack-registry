/////////////////////////////////////////////////
// TEMPALTE job_name
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- if not .loki.job_name ]][[ .nomad_pack.pack.name ]]
[[- else ]][[ .loki.job_name ]]
[[- end ]][[ end ]]
