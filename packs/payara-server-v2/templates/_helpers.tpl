[[- /*
////////////////////////
// Job Name
////////////////////////
*/ -]]

[[- define "job_name" -]]
[[ coalesce ( var "job_name" .) (meta "pack.name" .) | quote ]]
[[- end -]]


[[- /*
////////////////////////
// Constraints
////////////////////////
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
////////////////////////
// env_vars
////////////////////////
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
////////////////////////
// Task Resources
////////////////////////
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
////////////////////////
// Templatefiles
////////////////////////
*/ -]]

[[ define "templatefile" -]]
[[- with . ]][[ $tpl := . ]]

      template {
        change_mode = "restart"
        perms       = "666"
        destination = "/local/[[ $tpl.filename ]]"
        
        data = <<-HEREDOC
        [[ $tpl.content | nindent 8 | trim ]]
        HEREDOC
      }
[[- end ]][[ end ]]


[[- /*
////////////////////////
// Mounts
////////////////////////
*/ -]]

[[ define "mount" -]]
[[- with . ]][[ $mnt := . ]][[ if $mnt.mountpath ]]

        mount {
          type   = "bind"
          source = "local/[[ $mnt.filename ]]"
          target = "[[ $mnt.mountpath ]]/[[ $mnt.filename ]]"
        }
[[- end ]][[ end ]][[ end ]]


[[- /*
////////////////////////
// Artifact
////////////////////////
*/ -]]

[[ define "artifact" -]]
[[- with . ]][[ $artifact := . ]]

      artifact {
        source = [[ $artifact.source | toJson ]]
        destination = [[ $artifact.destination | toJson ]]
        mode = [[ $artifact.mode | toJson ]]
        
        [[- if not $artifact.options | empty ]]
        options {
          [[- range $k,$v := $artifact.options ]]
          [[ $k ]] = [[ $v | toJson ]]
          [[- end ]]
        }
        [[- end ]]
      }
[[- end ]][[ end ]]
