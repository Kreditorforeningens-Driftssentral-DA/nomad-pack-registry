# ACTIVEMQ

## Features

* Optional tasks: postgres (w/init-waiter), adminer

## Example use
```hcl
# Pack-commands
nomad-pack plan --name=demo-amq -f ./example.hcl packs/activemq
nomad-pack run --name=demo-amq -f ./example.hcl packs/activemq
nomad-pack stop --purge --name=demo-amq -f ./example.hcl packs/activemq
```

```hcl
// File: example.hcl
//////////////////////////////////
// NOMAD JOB variables
//////////////////////////////////

job_name = "demo-amq"

#task_enabled_postgres = true
#task_enabled_adminer = true

meta = {
  "deployment-id" = "2022-05-03.3" // Forces re-deploy
}

resources = {
  cpu = 100 // Soft-limit
  memory = 512 // Soft-limit
  memory_max = 1024 // Hard-limit
}

ephemeral_disk = {
  sticky  = true
  migrate = true
  size    = 1000
}

exposed_ports = [{
  name = "web"
  target = 8161
  static = -1
}]

//////////////////////////////////
// CONSUL service settings
//////////////////////////////////

consul_services = [{
  name = "amq-web"
  port = "8161"
  tags = ["traefik.enable=true"]
  sidecar_cpu = 100
  sidecar_memory = 64
  upstreams = []
},{
  name = "amq-autoTransport"
  port = "5671"
  tags = ["traefik.enable=false"]
  sidecar_cpu = 100
  sidecar_memory = 128
  upstreams = []
}]

//////////////////////////////////
// ACTIVEMQ task settings
//////////////////////////////////

environment = {
  ACTIVEMQ_DATA = "/alloc/data"
}

// CREATE FILES
// Stored in job-definition. Should use a config-service (e.g. Consul/Vault), or custom/private images.
files = [{
  name = "/local/jetty-realm.properties"
  content = <<-HEREDOC
  # Web Console access. <username>: <password>, <role>
  batman: manbat, admin
  user: user, user
  HEREDOC
},{
  name = "/local/credentials.properties"
  content = <<-HEREDOC
  # Broker/queue access
  activemq.username=batman
  activemq.password=manbat
  guest.password=guest
  HEREDOC
},{
  name = "/local/users.properties"
  content = "admin=batman"
},{
  name = "/local/groups.properties"
  content = "admins=batman"
},{
  name = "/local/activemq.xml"
  content = <<HEREDOC
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:amq="http://activemq.apache.org/schema/core" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">
<bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
<property name="locations">
  <value>file:$${activemq.conf}/credentials.properties</value>
</property></bean>
<broker xmlns="http://activemq.apache.org/schema/core" brokerName="broker" persistent="true" useShutdownHook="false" dataDirectory="$${activemq.data}">
<persistenceAdapter>
  <kahaDB directory="$${activemq.data}/kahadb"/>
</persistenceAdapter>
<destinationPolicy>
  <policyMap><policyEntries>
  <policyEntry topic=">" producerFlowControl="true">
  <pendingMessageLimitStrategy>
  <constantPendingMessageLimitStrategy limit="1000"/>
  </pendingMessageLimitStrategy>
  </policyEntry><policyEntry queue=">" producerFlowControl="true" memoryLimit="1mb"></policyEntry>
  </policyEntries></policyMap>
</destinationPolicy>
<managementContext><managementContext createConnector="false"/></managementContext>
<systemUsage><systemUsage>
  <memoryUsage><memoryUsage limit="64 mb"/></memoryUsage>
  <storeUsage><storeUsage limit="5 gb"/></storeUsage>
  <tempUsage><tempUsage limit="1 gb"/></tempUsage>
</systemUsage></systemUsage>
<transportConnectors>
  <transportConnector name="auto" uri="auto://localhost:5671?maxConnectionThreadPoolSize=100"/>
  <!-- AUTO supports both openwire & stomp
  <transportConnector name="openwire" uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
  <transportConnector name="stomp" uri="stomp://0.0.0.0:61613"/>
  -->
</transportConnectors>
<shutdownHooks>
  <bean xmlns="http://www.springframework.org/schema/beans" class="org.apache.activemq.hooks.SpringContextHook"/>
</shutdownHooks>
</broker>
<import resource="jetty.xml"/>
</beans>
HEREDOC
}]

// CONFIG-FILE OVERRIDES
// Overwrite default files in container image w/generated files
mounts = [{
  source = "local/activemq.xml"
  target = "/opt/activemq/conf/activemq.xml"
},{
  source = "local/jetty-realm.properties"
  target = "/opt/activemq/conf/jetty-realm.properties"
},{
  source = "local/credentials.properties"
  target = "/opt/activemq/conf/credentials.properties"
},{
  source = "local/users.properties"
  target = "/opt/activemq/conf/users.properties"
},{
  source = "local/groups.properties"
  target = "/opt/activemq/conf/groups.properties"
}]

```

