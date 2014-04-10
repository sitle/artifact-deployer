Artifact Deployer
---

A Chef Cookbook that wraps the (Apache) Maven recipe that makes dependency fetching and unpacking dead easy.
It also adds some DNS and JVM utils to automate Solr Cloud deployment on AWS

Here's how you can deploy Apache Solr on a running Apache Tomcat:

```
"maven": {
    "repos": {
        "maven-repo-id": {
            "url": "https://your.maven.repo/repo",
            "username": "mavenrepo-user",
            "password": "mavenrepo-pwd"
        }
    }
},
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
"jvm_host" : {
    "add_host_param" : true
},
"route53" : {
    "zone_id" : "XXXXXXXXXXXX",
    "aws_access_key_id" : "XXXXXXXXXXXXXXXXXXXX",
    "aws_secret_access_key" : "XXXXXXXXXXXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXX"
}
```

This configuration contains:
- The configuration for my personal Maven Artifact Repository that hosts my snapshot dependencies, including the configuration of the Solr instance to run
- The configuration for the deployment of 2 artifacts: the Solr WAR and configuration (aka SOLR_HOME)
- The configuration of the Solr host JVM Param (-Dhost=hostname.domain); hostname and domain are taken from AWS OpsWorks attributes
- The Route53 Zone (and AWS auth) info that allows to subscribe the current machine DNS entry