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
  destinationName = artifact[:destinationName] ? artifact[:destinationName] : "#{artifactName}"
  enabled         = artifact[:enabled] ? artifact[:enabled] : false
  properties      = artifact[:properties] ? artifact[:properties] : []
  terms           = artifact[:terms] ? artifact[:terms] : []
  filtering_mode  = artifact[:filtering_mode] ? artifact[:filtering_mode] : "replace"
  fileNameWithExt = "#{destinationName}.#{artifactType}"
  destinationPath = "#{destination}/#{destinationName}"

  if enabled == true
    log "Processing artifact #{destinationName}.#{artifactType}; unzip: #{unzip}"
    if path
      fileNameWithExt = File.basename(path)
      execute "cache-artifact-#{destinationName}" do
        command       "cp -Rf #{path} #{chef_cache}/#{fileNameWithExt}"
      end
    elsif url
      fileNameWithExt = File.basename(url)
      remote_file     "#{chef_cache}/#{fileNameWithExt}" do
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

    directory "fix-permissions-#{destination}" do
      path          destination
      owner         owner
      action        :create
    end

    if unzip == true
      execute "unzipping-package-#{destinationName}" do
        command     "unzip -q -u -o  #{chef_cache}/#{fileNameWithExt} #{subfolder} -d #{destinationPath}; chown -R #{owner} #{destinationPath}; chmod -R 755 #{destinationPath}"
        user        owner
        only_if     "test -f #{chef_cache}/#{fileNameWithExt}"
      end
    else
      execute "copying-package-#{fileNameWithExt}" do
        command     "cp -Rf #{chef_cache}/#{fileNameWithExt} #{destination}/#{fileNameWithExt}; chown -R #{owner} #{destination}/#{fileNameWithExt}"
        user        owner
        only_if     "test -f #{chef_cache}/#{fileNameWithExt}"
      end
    end

    properties.each do |fileToPatch, propertyMap|
      filtering_mode  = propertyMap[:filtering_mode] ? propertyMap[:filtering_mode] : filtering_mode
      if filtering_mode == "replace"
        propertyMap.each do |propName, propValue|
          file_replace_line "#{destinationPath}/#{fileToPatch}" do
            replace   "#{propName}="
            with      "#{propName}=#{propValue}"
            only_if   "test -f #{destinationPath}/#{fileToPatch}"
          end
        end
      elsif filtering_mode == "append"
        propertyMap.each do |propName, propValue|
          file_append "#{destinationPath}/#{fileToPatch}" do
            line      "#{propName}=#{propValue}"
            only_if   "test -f #{destinationPath}/#{fileToPatch}"
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
