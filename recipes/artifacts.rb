repositories = []
node[:maven][:repos].each do |repoName, repo|
  repositories.push "#{repoName}::::#{repo[:url]}"
end

chef_cache   = "/var/chef/cache"
directory "chef-cache" do
  path    chef_cache
  owner   "root"
  group   "root"
  mode    00755
  action  :create
end

node[:artifacts].each do |artifactName, artifact|

  artifactType  = artifact[:type] ? artifact[:type] : "jar"
  owner         = artifact[:owner] ? artifact[:owner] : "root"
  unzip         = artifact[:unzip] ? artifact[:unzip] : false
  classifier    = artifact[:classifier] ? artifact[:classifier] : ""
  destination   = artifact[:destination]
  enabled       = artifact[:enabled]
  properties    = artifact[:properties]

  if enabled == true
    maven "#{artifactName}" do
      artifact_id   artifact[:artifactId]
      group_id      artifact[:groupId]
      version       artifact[:version]
      if classifier != ''
        classifier  classifier
      end
      action        :put
      dest          chef_cache
      owner         owner
      packaging     artifactType
      repositories  repositories
    end

    directory "fix-permissions-on-destination-folder-for-#{artifactName}" do
      path    destination
      owner   owner
      action  :create
      subscribes  :create, "maven[#{artifactName}]"
    end

    if unzip == true
      execute "unzipping_package-#{artifactName}" do
        command     "unzip -q -u -o  #{chef_cache}/#{artifactName}.#{artifactType} -d #{destination}/#{artifactName}; chown -R #{owner} #{destination}/#{artifactName}; chmod -R 755 #{destination}/#{artifactName}"
        user        owner
      end
      
      properties.each do |fileToPatch, propertyMap|
        propertyMap.each do |propName, propValue|
          file_replace_line "#{destination}/#{artifactName}/#{fileToPatch}" do
            replace "#{propName}="
            with    "#{propName}=#{propValue}"
          end
        end
      end
        
    else
      execute "unzipping_package-#{artifactName}" do
        command     "cp -Rf #{chef_cache}/#{artifactName}.#{artifactType} #{destination}/#{artifactName}.#{artifactType}; chown -R #{owner} #{destination}/#{artifactName}.#{artifactType}"
        user        owner
      end
    end
  end
end


