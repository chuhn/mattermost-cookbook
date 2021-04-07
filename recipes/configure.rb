#
# Cookbook Name:: mattermost-cookbook
# Recipes:: configure
#
# Copyright 2020-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

# enable local mode first:
# This has to happen before mattermost_cookbook_mmctl becomes available
mattermost_cookbook_config 'ServiceSettings.LocalModeSocketLocation' do
  value node['mattermost']['config']['mmctl_socket']
end

mattermost_cookbook_config 'ServiceSettings.EnableLocalMode' do
  value true
  notifies :restart, 'service[mattermost]', :immediately
end

node['mattermost']['app'].each do |group, settings|
  case group
  when 'sql_settings'
    # some sql_settings require different handling (see below)
    next
  else
    settings.each do |key, val|
      # make sure TLS is turned on after certificates have been configured
      next if key == 'connection_security'
      mattermost_cookbook_mmctl "#{group}.#{key}" do
        value val.to_s
        ignore_failure true # ???
      end
    end

    # finally configure connection security:
    mattermost_cookbook_mmctl "#{group}.ConnectionSecurity" do
      value settings['connection_security']
      ignore_failure true # ???
      only_if { settings.key?('connection_security') }
      notifies :restart, 'service[mattermost]'
    end
  end
end

#
# database setup (adapted from config.json.erb template)
#

mattermost_cookbook_config 'SqlSettings.DriverName' do
  value node['mattermost']['app']['sql_settings']['driver_name']
end

mattermost_cookbook_config 'SqlSettings.DataSource' do
  value format_dsn
end

if node['mattermost']['app']['sql_settings']['data_source_replicas']
  data_source_replicas = node['mattermost']['app']['sql_settings']['data_source_replicas'].map do |replica|
    format_dsn(hostname: replica)
  end

  mattermost_cookbook_config 'SqlSettings.DataSourceReplicas' do
    value data_source_replicas.join(',')
  end
end


if node['mattermost']['app']['sql_settings']['data_source_search_replicas']
  data_source_search_replicas = node['mattermost']['app']['sql_settings']['data_source_search_replicas'].map do |replica|
    format_dsn(hostname: replica)
  end

  mattermost_cookbook_config 'SqlSettings.DataSourceSearchReplicas' do
    value data_source_search_replicas.join(',')
  end
end
