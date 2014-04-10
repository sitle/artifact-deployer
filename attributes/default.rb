default['jvm_host']['tomcat_defaults_path'] = "/etc/default/tomcat7"

default['jvm_host']['add_host_param'] = true
default['jvm_host']['param_name'] = "host"
default['jvm_host']['hostname'] = "#{node[:hostname]}.#{node[:resolver][:search]}"
