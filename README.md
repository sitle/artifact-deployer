Artifact Deployer
---

A Chef Cookbook that provides a simple way to download, unpack and configure artifacts.
Download is offered via
- Maven GAV coordinates
- HTTP Url
- File-system path

```
"artifacts": {
    "solr-home": {
        "enabled": true,
        "url": "https://artifacts.alfresco.com/nexus/service/local/artifact/maven/redirect?r=releases&g=org.alfresco&a=alfresco-solr&v=5.0.a&e=zip&c=config",
        "destination": "/var/lib/tomcat7",
        "owner": "tomcat7",
        "unzip": true
    },
    "alfresco": {
        "enabled": true,
        "groupId": "org.alfresco",
        "artifactId": "alfresco",
        "type": "war",
        "version": "5.0.a",
        "destination": "/var/lib/tomcat7/webapps",
        "owner": "tomcat7"
    },
    "pathPrefix" : "/vagrant",
    "my-amp": {
        "enabled": true,
        "path": "my-amp/target/my-amp.amp",
        "destination": "/var/lib/tomcat7/amps",
        "owner": "tomcat7"
    }
}
```
Unpacking and filtering
---

```
"artifacts": {
    "solr-home": {
        "enabled": true,
        "url": "https://artifacts.alfresco.com/nexus/service/local/artifact/maven/redirect?r=releases&g=org.alfresco&a=alfresco-solr&v=5.0.a&e=zip&c=config",
        "destination": "/var/lib/tomcat7",
        "owner": "tomcat7",
        "unzip": true,
        "filtering_mode" : "replace",
        "properties" : {
          "archive-SpacesStore/conf/solrcore.properties" : [
            "alfresco.host" : "192.168.0.22",
            "solr.secureComms" : "none"
          ],
          "test.properties" : [
            "my.host" : "192.168.0.22",
            "filtering_mode" : "append"
          ]
        },
        "terms" : {
          "context.xml" : [
            "@@ALFRESCO_HOST@@" : "192.168.0.22"
          ]
        }
    }
}
```

Filtering can be used via ```terms``` or ```properties``` attributes defined within the artifact configuration; each of those contain a list of ```file path(String) => attributes(Map<String,String>)```, where
- *file path* is the path, within the unpacked ZIP file, of the file that needs to be patched
- *attributes* maps the original string with the new ones to be injected

When using ```terms```, each attribute's key is replaced with the attribute's value.

When using ```properties```, a file line starting with ```<key>=``` will be searched and replaced with ```<key>=<value>```; if the line doesn't exist, by default nothing will happen (unless ```filtering_mode``` is set to ```append```); if the file doesn't exist, it will be created.

```filtering_mode``` can be specified at artifact level or as an attribute of properties, as shown in the example above.

Maven Private Repositories
---
To access private Maven repositories, you can easily define your credentials (password encryption is supported, although it's strongly recommended to wipe out your Maven settings right after Chef installation is terminated)

```
"maven": {
    "repos": {
        "maven-repo-id": {
            "url": "https://your.maven.repo/repo",
            "username": "mavenrepo-user",
            "password": "mavenrepo-pwd"
        }
    }
}
```

DNS and JVM Utils
---
Artifact Deployer also includes some DNS and JVM utils to automate AWS deployments.

The following configuration contains:
- JVM ```-Dhost=hostname.domain``` param; hostname and domain are taken from AWS OpsWorks attributes
- Route53 Zone (and AWS auth) info that allows to subscribe the current machine DNS entry

```
"jvm_host" : {
    "add_host_param" : true
},
"route53" : {
    "zone_id" : "XXXXXXXXXXXX",
    "aws_access_key_id" : "XXXXXXXXXXXXXXXXXXXX",
    "aws_secret_access_key" : "XXXXXXXXXXXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXX"
}
```
