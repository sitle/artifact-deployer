Artifact Deployer
---

A Chef Cookbook that wraps the (Apache) Maven recipe that makes dependency fetching and unpacking dead easy.

Here's how you can deploy Apache Solr on a running Apache Tomcat:

```
"artifacts": {
    "solr-home": {
        "groupId": "it.session.solr",
        "artifactId": "solr-data",
        "type": "zip",
        "classifier": "solr-home",
        "version": "0.1-SNAPSHOT",
        "destination": "/var/lib/tomcat7",
        "owner": "tomcat7",
        "unzip": true
    },
    "solr": {
        "groupId": "org.apache.solr",
        "artifactId": "solr",
        "type": "war",
        "version": "4.7.1",
        "destination": "/var/lib/tomcat7/webapps",
        "owner": "tomcat7"
    }
},
"opsworks_java" : {
    "jvm_options" : "-Xmx700M -XX:MaxPermSize=200M -Dsolr.solr.home=/var/lib/tomcat7/solr-home -Dsolr.data.dir=/var/lib/tomcat7/solr-data",
    "add_host_param" : true
},
"route53" : {
    "zone_id" : "Z2XX8ADRID4STQ",
    "aws_access_key_id" : "XXXXXXXXXXXXXXXXXXXX",
    "aws_secret_access_key" : "XXXXXXXXXXXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXX"
}
```

This configuration contains:
- The configuration for my personal Maven Artifact Repository that hosts my snapshot dependencies, including the configuration of the Solr instance to run
- The configuration for the deployment of 2 artifacts: the Solr WAR and configuration (aka SOLR_HOME)
- The configuration of the JVM_OPTS mentioning the paths used for Solr installation; this option definition depends on the container you'll be using
  - the _add_host_param_ attributes adds a -Dhost=<hostname>.<domain> in the JVM params, which is crucial for Solr Cloud deployments
- The Route53 Zone (and AWS auth) info that allows to subscribe the current machine DNS entry 