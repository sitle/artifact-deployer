if node.attribute?("jvm_host")
  
  tomcat_defaults_path = node[:jvm_host][:tomcat_defaults_path]
  add_host_param = node[:jvm_host][:add_host_param]
  param_name = node[:jvm_host][:param_name]
  hostname = node[:jvm_host][:hostname] || "#{node[:hostname]}.#{node[:resolver][:search]}"

  if add_host_param
    ruby_block "Add JVM params to Tomcat" do
      block do
        Chef::Log.info("Patching file '#{tomcat_defaults_path}' with additional JAVA_OPTS #{paramName}=#{hostname}")
        fe = Chef::Util::FileEdit.new(tomcat_defaults_path)
        jvm_opts = "-D#{param_name}=#{hostname}"
        fe.insert_line_if_no_match(/Dmanaged_by_chef/, "JAVA_OPTS=\"${JAVA_OPTS} #{jvm_opts}\" ##managed_by_chef")
        fe.write_file
      end
    end
  end
end