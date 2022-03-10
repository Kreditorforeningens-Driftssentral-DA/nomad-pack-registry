/////////////////////////////////////////////////
// "job_name" template
/////////////////////////////////////////////////

[[- define "job_name" ]]
[[- coalesce .bitbucket_runner.job_name .nomad_pack.pack.name | print ]][[ end ]]

/////////////////////////////////////////////////
// "datacenters" template
/////////////////////////////////////////////////

[[- define "datacenters" ]]
[[- $dcs := coalesce .bitbucket_runner.datacenters (list "dc1") ]]
[[ cat "datacenters" "=" ($dcs|toPrettyJson) | print | indent 2 ]]
[[- end ]]

/////////////////////////////////////////////////
// "namespace" template
/////////////////////////////////////////////////

[[- define "namespace" ]][[ if .bitbucket_runner.namespace | empty | not ]]
[[ cat "namespace" "=" (.bitbucket_runner.namespace|quote) | print | indent 2 ]]
[[- end ]][[ end ]]

