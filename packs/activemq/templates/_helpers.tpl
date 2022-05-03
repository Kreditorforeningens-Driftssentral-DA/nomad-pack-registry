/////////////////////////////////////////////////
// "job_name" template
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- coalesce .activemq.job_name .nomad_pack.pack.name | print ]][[ end ]]

/////////////////////////////////////////////////
// "datacenters" template
/////////////////////////////////////////////////

[[- define "datacenters" ]]
[[- $dcs := coalesce .activemq.datacenters (list "dc1") ]]
[[ cat "datacenters" "=" ($dcs|toPrettyJson) | print | indent 2 ]]
[[- end ]]

/////////////////////////////////////////////////
// "namespace" template
/////////////////////////////////////////////////

[[- define "namespace" ]][[ if .activemq.namespace | empty | not ]]
[[ cat "namespace" "=" (.activemq.namespace|quote) | print | indent 2 ]]
[[- end ]][[ end ]]

