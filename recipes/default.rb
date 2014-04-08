if node.attribute?("maven")
  template  "#{node['maven']['m2_home']}/conf/settings.xml" do
    source  "settings.xml.erb"
    mode    0666
    owner   "root"
    group   "root"
  end

  link "/usr/bin/mvn" do
    to "/usr/local/maven/bin/mvn"
  end
end

include_recipe "artifact-deployer::artifacts"
include_recipe "artifact-deployer::route53"
