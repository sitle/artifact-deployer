include_recipe "artifact-deployer::artifacts"

unless node['maven'].empty?
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