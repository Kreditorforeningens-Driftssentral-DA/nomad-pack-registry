app {
  url    = "https://activemq.apache.org/components/classic/documentation"
  author = "Apache Software Foundation"
}

pack {
  name    = "activemq-v2"
  version = "0.1.1"
  
  description = <<-HEREDOC
    This is a pack for deploying Apache ActiveMQ (Classic).
    Optionally, you can deploy telegraf and/or fluentbit sidecars
    for monitoring.
    HEREDOC
}
