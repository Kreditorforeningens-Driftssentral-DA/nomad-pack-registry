/////////////////////////////////////////////////
// "job_name" template
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- coalesce .payara_server.job_name .nomad_pack.pack.name | print ]][[ end ]]

/////////////////////////////////////////////////
// "datacenters" template
/////////////////////////////////////////////////

[[- define "datacenters" ]]
[[- $dcs := coalesce .payara_server.datacenters (list "dc1") ]]
[[ cat "datacenters" "=" ($dcs|toPrettyJson) | print | indent 2 ]]
[[- end ]]

/////////////////////////////////////////////////
// "namespace" template
/////////////////////////////////////////////////

[[- define "namespace" ]][[ if .payara_server.namespace | empty | not ]]
[[ cat "namespace" "=" (.payara_server.namespace|quote) | print | indent 2 ]]
[[- end ]][[ end ]]

