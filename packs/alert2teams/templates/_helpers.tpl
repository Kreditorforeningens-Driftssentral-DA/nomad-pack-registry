////////////////////////
// "job_name" template
////////////////////////

[[- define "job_name" ]]
[[- coalesce .my.job_name .nomad_pack.pack.name | print ]][[ end ]]

