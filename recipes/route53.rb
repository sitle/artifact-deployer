if node.attribute?("route53")
  
  ruby_block "Create DNS entry in Route53" do
    block do
      routeClient = Route53::Client.new(node[:route53][:aws_access_key_id], node[:route53][:aws_secret_access_key])
      routeClient.create_or_update_record("#{node[:opsworks][:instance][:hostname]}.#{node[:resolver][:search]}.", node[:opsworks][:instance][:private_ip], "A", node[:route53][:zone_id])
    end
    action :create
  end  
end