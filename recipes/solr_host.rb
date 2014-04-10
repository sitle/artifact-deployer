if node.attribute?("solr_host")
  
  tomcat_default = node[:solr_host][:tomcat_path]
  add_host_param = node[:solr_host][:add_host_param]

  if add_host_param do
    ruby_block "Add JVM params to Tomcat" do
      block do
        fe = Chef::Util::FileEdit.new(tomcat_default)
        jvm_opts = "-Dhost=#{node[:hostname]}.#{node[:resolver][:search]}"
        fe.insert_line_if_no_match(/Dmanaged_by_chef/, "JAVA_OPTS=\"${JAVA_OPTS} #{jvm_opts}\" ##managed_by_chef")
        fe.write_file
      end
    end
  end
end