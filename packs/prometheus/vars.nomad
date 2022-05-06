// Example

job_name = "demo-prometheus"

// Do not expose any ports on the host
#ports = []

// Best-effort to persist allocation data

ephemeral_disk = {
  size = 300
  migrate = true
  sticky = true
}

// Create file & mount inside container

custom_files = [{
  destination = "/local/info.txt"
  data = <<HEREDOC
  Just a plain text-file
  HEREDOC
}]

custom_mounts = [{
  source = "local/info.txt"
  target = "/info.txt"
}]

// Override startup-command

args = [
  "--config.file=/etc/prometheus/prometheus.yml",
  "--storage.tsdb.path=/local/prometheus",
  "--storage.tsdb.retention.time=1h",
  "--storage.tsdb.retention.size=100MB",
  "--web.console.libraries=/usr/share/prometheus/console_libraries",
  "--web.console.templates=/usr/share/prometheus/consoles",
  "--log.format=json",
]
