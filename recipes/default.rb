restart_services = node['restart_services']

include_recipe "maven::default"

if node.attribute?("maven")
  template  "#{node['maven']['m2_home']}/conf/settings.xml" do
    source  "settings.xml.erb"
    mode    0666
    owner   "root"
    group   "root"
    subscribes :create, "ark[maven]", :immediately
  end

  link "/usr/bin/mvn" do
    to "/usr/local/maven/bin/mvn"
    subscribes :create, "template[#{node['maven']['m2_home']}/conf/settings.xml]", :immediately
  end
end

include_recipe "artifact-deployer::artifacts"
include_recipe "artifact-deployer::route53"
include_recipe "artifact-deployer::jvm_host"

restart_services.each do |serviceName|
  service serviceName  do
    action      :restart
  end
end
