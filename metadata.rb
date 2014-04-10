name              "artifact-deployer"
maintainer        "Maurizio Pillitu"
maintainer_email  "maurizio@session.it"
license           "Apache 2.0"
description       "A wrapper of the chef (Apache) Maven recipe that makes dependency fetching and unpacking dead easy"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1"

depends "maven"

recipe 'default', 'Installs Apache Maven'
recipe 'artifacts', 'Installs Maven artifacts'
recipe 'route53', 'Installs Maven artifacts'
recipe 'solr_host', 'Adds -Dhost=#{node[:hostname]}.#{node[:resolver][:search]} to the Tomcat opts'