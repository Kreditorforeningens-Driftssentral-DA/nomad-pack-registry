[[- /*
 Template Helpers

 This file contains Nomad pack template helpers. Any information outside of a
 `define` template action is informational and is not rendered, allowing you
 to write comments and implementation details about your helper functions here.
 Some helper functions are included to get you started.
*/ -]]

[[- /*
=================================================
 `job_name` helper

 This helper demonstrates how to use a variable value or fall back to the pack's
 metadata when that value is set to a default of "".
=================================================
*/ -]]

[[- define "job_name" -]]
[[ coalesce ( var "job_name" .) (meta "pack.name" .) | quote ]]
[[- end -]]


[[- /*
=================================================
 `constraint` helper

```
  `list(object(attribute string, operator string, value string))`
```
=================================================
*/ -]]

[[- define "constraint" -]]
[[ range $idx, $constraint := . ]]

  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[ end ]]
[[- end -]]


[[- /*
=================================================
 `env_vars` helper

 This helper formats maps as key and quoted value pairs as map(string).
=================================================
*/ -]]

[[ define "env_vars" -]]
[[- with . ]]
      
      env {
        [[- range $key, $value := . ]]
        [[ $key ]] = [[ $value | quote ]]
        [[- end ]]
      }
[[- end ]]
[[- end ]]


[[- /*
=================================================
 `resources` helper

 This helper formats values of object(cpu number, memory number) as a `resources`
 block
=================================================
*/ -]]

[[ define "resources" -]]
[[- with . ]][[ $res := . ]]
      
      resources {
        cpu        = [[ $res.cpu ]]
        memory     = [[ $res.memory ]]
        
        [[- with $res.cpu_strict ]]
        cpu_strict = [[ . ]][[- end ]]
        
        [[- if gt $res.memory_max $res.memory ]]
        memory_max = [[ $res.memory_max ]][[- end ]]
      }
[[- end ]][[ end ]]


[[- /*
=================================================
 `templatefile` helper

 This helper creates a file in the /local path of the task.
=================================================
*/ -]]

[[ define "templatefile" -]]
[[- with . ]][[ $tpl := . ]]

      template {
        change_mode = "restart"
        perms       = "444"
        destination = "/local/[[ $tpl.filename ]]"
        
        data = <<-HEREDOC
        [[ $tpl.content | nindent 8 | trim ]]
        HEREDOC
      }
[[- end ]][[ end ]]


[[- /*
=================================================
 `mount` helper

 This helper mounts a templated file from the 'local'
 path of the task into the container filesystem.
=================================================
*/ -]]

[[ define "mount" -]]
[[- with . ]][[ $mnt := . ]]
[[- if $mnt.mountpath ]]

        mount {
          type   = "bind"
          source = "local/[[ $mnt.filename ]]"
          target = "[[ $mnt.mountpath ]]/[[ $mnt.filename ]]"
        }
[[ end ]]
[[- end ]][[ end ]]
