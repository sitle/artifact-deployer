include_recipe "maven::default"

m2_home = node['maven']['m2_home']

template  "#{m2_home}/conf/settings.xml" do
  source  "settings.xml.erb"
  mode    0666
  owner   "root"
  group   "root"
  variables(
    :repos => MavenReposCookbook.repos
  )
  subscribes :create, "ark[maven]", :immediately
end

link "/usr/bin/mvn" do
  to "/usr/local/maven/bin/mvn"
  subscribes :create, "template[#{m2_home}/conf/settings.xml]", :immediately
end

include_recipe "artifact-deployer::artifacts"
include_recipe "artifact-deployer::route53"
include_recipe "artifact-deployer::jvm_host"