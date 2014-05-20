#
# Cookbook Name:: artifact-deployer
# Library:: artifact_deployer_cookbook
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2010-2012, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  module MavenReposCookbook
    class MavenReposCookbookError < StandardError; end
    class InvalidRepoDataBagItem < MavenReposCookbookError
      attr_reader :item

      def initialize(item)
        @item = item
      end

      def to_s
        msg = "The item you provided: #{item.inspect} in the #{REPOS_DATA_BAG} was invalid. Items "
        msg << "require a 'id', 'username', and 'password' field. Consult the documentation for further instructions."
      end
    end

    class MavenRepoDataBagNotFound < MavenReposCookbookError
      def to_s
        "Please create a data bag named '#{REPOS_DATA_BAG}' and try again."
      end
    end

    REPOS_DATA_BAG = 'maven_repos'

    class << self
      # Returns a array of data bag items for the repos in the Maven Repos
      # data bag. All items are validated before returning.
      #
      # @raise [MavenReposCookbook::InvalidRepoDataBagItem] if an invalid item
      #   was found in the Maven repos data bag.
      #
      # @return [Array<Chef::DataBagItem>, Array<Chef::EncryptedDataBagItem>]
      def repos
        @repos ||= find_repos
      end

      private

      def find_repos
        repos = if Chef::Config[:solo]
                  data_bag = Chef::DataBag.load(REPOS_DATA_BAG)
                  data_bag.keys.map do |name|
            Chef::DataBagItem.load(REPOS_DATA_BAG, name)
          end
                else
                  begin
                    items = Chef::Search::Query.new.search(REPOS_DATA_BAG)[0]
                  rescue Net::HTTPServerException => e
                    raise MavenRepoDataBagNotFound if e.message.match(/404/)
                    raise e
                  end
                  decrypt_items(items)
                end

        repos.each { |repo| validate_repo_item(repo) }
        repos
      end

      def validate_repo_item(repo)
        if repo['id'].empty? || repo['id'].nil? && repo['url'].empty? || repo['url'].nil?
          fail InvalidRepoDataBagItem.new(repo), 'Invalid Maven Repo Databag Item'
        end
      end

      def decrypt_items(items)
        items.map do |item|
          EncryptedDataBagItem.new(item, encrypted_secret)
        end
      end

      def encrypted_secret
        @encrypted_secret ||= EncryptedDataBagItem.load_secret
      end
    end
  end
end
