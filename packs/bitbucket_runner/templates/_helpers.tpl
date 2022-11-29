//////////////////////////////////
// Job Name
//////////////////////////////////

[[- define "job_name" ]]
[[- coalesce .my.job_name .nomad_pack.pack.name | print ]][[ end ]]

//////////////////////////////////
// Datacenters
//////////////////////////////////

[[- define "datacenters" ]]
[[- $dcs := coalesce .my.datacenters (list "dc1") ]]
[[ cat "datacenters" "=" ($dcs|toPrettyJson) | print | indent 2 ]]
[[- end ]]

//////////////////////////////////
// Namespace
//////////////////////////////////

[[- define "namespace" ]][[ if .my.namespace | empty | not ]]
[[ cat "namespace" "=" (.my.namespace|quote) | print | indent 2 ]]
[[- end ]][[ end ]]
