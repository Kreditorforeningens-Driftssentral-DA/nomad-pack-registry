/////////////////////////////////////////////////
// "job_name" template
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- coalesce .example.job_name .nomad_pack.pack.name | print ]][[ end ]]

/////////////////////////////////////////////////
// "datacenters" template
/////////////////////////////////////////////////

[[- define "datacenters" ]]
[[- $dcs := coalesce .example.datacenters (list "dc1") ]]
[[ cat "datacenters" "=" ($dcs|toPrettyJson) | print | indent 2 ]]
[[- end ]]

/////////////////////////////////////////////////
// "namespace" template
/////////////////////////////////////////////////

[[- define "namespace" ]][[ if .example.namespace | empty | not ]]
[[ cat "namespace" "=" (.example.namespace|quote) | print | indent 2 ]]
[[- end ]][[ end ]]

