include_recipe "maven::default"

m2_home         = node['maven']['m2_home']
master_password = node['maven']['master_password']
purge_settings = node['maven']['purge_settings']

template  "#{m2_home}/conf/settings.xml" do
  source  "settings.xml.erb"
  mode    0666
  owner   "root"
  group   "root"
  variables(
    :repos => MavenReposCookbook.repos
  )
end

if !master_password.empty?
  directory  "/root/.m2" do
    mode    0666
    owner   "root"
    group   "root"
  end

  template  "/root/.m2/settings-security.xml" do
    source  "settings-security.xml.erb"
    mode    0666
    owner   "root"
    group   "root"
  end
end

link "/usr/bin/mvn" do
  to "/usr/local/maven/bin/mvn"
end

include_recipe "artifact-deployer::artifacts"
include_recipe "artifact-deployer::route53"
include_recipe "artifact-deployer::jvm_host"

if purge_settings == true
  file "#{m2_home}/conf/settings.xml" do
    action :delete
  end
  directory  "/root/.m2" do
    action :delete
  end
end
