term_delimiter_start = node['term_delimiter_start']
term_delimiter_end = node['term_delimiter_end']
property_equals_sign = node['property_equals_sign']


@maven_repos = MavenReposCookbook.repos
maven_repos_str = []
@maven_repos.each do |repo|
  maven_repos_str.push "#{repo['id']}::::#{repo['url']}"
end

chef_cache   = "/var/chef/cache"
directory "chef-cache" do
  path    chef_cache
  owner   "root"
  group   "root"
  mode    00755
  action  :create
end

pathPrefix = node[:artifactPathPrefix]
node[:artifacts].each do |artifactName, artifact|
  url             = artifact[:url]
  path            = artifact[:path] ? "#{pathPrefix}/#{artifact[:path]}" : nil
  artifact_id     = artifact[:artifactId]
  group_id        = artifact[:groupId]
  version         = artifact[:version]
  artifactType    = artifact[:type] ? artifact[:type] : "jar"
  owner           = artifact[:owner] ? artifact[:owner] : "root"
  unzip           = artifact[:unzip] ? artifact[:unzip] : false
  classifier      = artifact[:classifier] ? artifact[:classifier] : ""
  subfolder       = artifact[:subfolder] ? artifact[:subfolder] : ""
  destination     = artifact[:destination]
  enabled         = artifact[:enabled] ? artifact[:enabled] : false
  properties      = artifact[:properties] ? artifact[:properties] : []
  terms           = artifact[:terms] ? artifact[:terms] : []
  filtering_mode  = artifact[:filtering_mode] ? artifact[:filtering_mode] : "replace"
  fileName        = "#{artifactName}.#{artifactType}"

  log "Processing artifact #{artifactName}.#{artifactType}; unzip: #{unzip}"

  if enabled == true
    if path
      fileName = File.basename(path)
      artifactType = File.extname(fileName).split('.').last
      execute "cache-artifact-#{artifactName}" do
        command       "cp -Rf #{path} #{chef_cache}/#{fileName}"
      end
    elsif url
      fileName = File.basename(url)
      artifactType = File.extname(fileName).split('.').last
      remote_file     "#{chef_cache}/#{fileName}" do
        source        url
      end
    elsif artifact_id and group_id and version
      maven "#{artifactName}" do
        artifact_id   artifact_id
        group_id      group_id
        version       version
        if classifier != ''
          classifier  classifier
        end
        action        :put
        dest          chef_cache
        owner         owner
        packaging     artifactType
        repositories  maven_repos_str
      end
    end

    directory "fix-permissions-on-destination-folder-for-#{artifactName}" do
      path          destination
      owner         owner
      action        :create
    end

    if unzip == true
      execute "unzipping-package-#{fileName}" do
        command     "unzip -q -u -o  #{chef_cache}/#{fileName} #{subfolder} -d #{destination}/#{artifactName}; chown -R #{owner} #{destination}/#{artifactName}; chmod -R 755 #{destination}/#{artifactName}"
        user        owner
        only_if     "test -f #{chef_cache}/#{fileName}"
      end
    else
      execute "copying-package-#{fileName}" do
        command     "cp -Rf #{chef_cache}/#{fileName} #{destination}/#{fileName}; chown -R #{owner} #{destination}/#{fileName}"
        user        owner
        only_if     "test -f #{chef_cache}/#{fileName}"
      end
    end

    properties.each do |fileToPatch, propertyMap|
      filtering_mode  = propertyMap[:filtering_mode] ? propertyMap[:filtering_mode] : filtering_mode
      if filtering_mode == "replace"
        propertyMap.each do |propName, propValue|
          file_replace_line "#{destination}/#{artifactName}/#{fileToPatch}" do
            replace   "#{propName}="
            with      "#{propName}=#{propValue}"
            only_if   "test -f #{destination}/#{artifactName}/#{fileToPatch}"
          end
        end
      elsif filtering_mode == "append"
        propertyMap.each do |propName, propValue|
          file_append "#{destination}/#{artifactName}/#{fileToPatch}" do
            line      "#{propName}=#{propValue}"
            only_if   "test -f #{destination}/#{artifactName}/#{fileToPatch}"
          end
        end
      end
    end

    terms.each do |fileToPatch, termMap|
      termMap.each do |termMatch, termReplacement|
        file_replace  "#{destination}/#{artifactName}/#{fileToPatch}" do
          replace     "#{term_delimiter_start}#{termMatch}#{term_delimiter_end}"
          with        "#{termReplacement}"
          only_if     "test -f #{destination}/#{artifactName}/#{fileToPatch}"
        end
      end
    end
  end
end
