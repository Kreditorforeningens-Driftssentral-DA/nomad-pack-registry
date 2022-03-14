/////////////////////////////////////////////////
// TEMPALTE job_name
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- if .fluentbit.job_name | empty ]][[ .nomad_pack.pack.name ]]
[[- else -]][[- .fluentbit.job_name ]]
[[- end ]][[ end ]]

/////////////////////////////////////////////////
// TEMPLATE datacenters
/////////////////////////////////////////////////

[[- define "datacenters" ]]
[[ cat "datacenters" "=" (.fluentbit.datacenters|toPrettyJson) | print | indent 2 ]][[ end ]]

/////////////////////////////////////////////////
// TEMPLATE namespace
/////////////////////////////////////////////////

[[- define "namespace" ]][[ if not .fluentbit.namespace | empty ]]
[[ cat "namespace" "=" (.fluentbit.namespace|quote) | print | indent 2 ]]
[[- end ]][[ end ]]
