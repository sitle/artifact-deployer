tomcat_default = node[:opsworks][:tomcat_default_path] || "/ect/default/tomcat"
jvm_opts = node[:opsworks][:jvm_options]
add_host_param = node[:opsworks][:add_host_param] || false

ruby_block "Add JVM params to Tomcat" do
  block do
    fe = Chef::Util::FileEdit.new(tomcat_default)
    if add_host_param do
      jvm_opts += "-Dhost=#{node[:hostname]}.#{node[:resolver][:search]}"
    end
    fe.insert_line_if_no_match(/Dmanaged_by_chef/, "JAVA_OPTS=\"${JAVA_OPTS} #{jvm_opts}\" ##managed_by_chef")
    fe.write_file
  end
end