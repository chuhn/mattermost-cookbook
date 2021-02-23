
# Cookbook Name:: mattermost-cookbook
# Custom resource to modify mattermost config
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
#
# lightweight resource to tweak the mattermost config via mmctl
#

property :name, String, name_attribute: true
property :value, String
property :config_json, String, default: node['mattermost']['config']['path']
property :socket, String, default: node['mattermost']['config']['mmctl_socket']

load_current_value do |new_resource|
  config = JSON.parse(::File.read(new_resource.config_json))
  new_resource.name.split('.').each do |key|
    tkey = mm_transform_key(key)
    return unless config.key?(tkey)
    config = config[tkey]
  end
  value config.to_s
end

action :set do
  converge_if_changed do
    transformed_key = name.split('.').map{|e| mm_transform_key(e)}.join('.')
    cmd = format('%s --local config set "%s" "%s"',
                   node['mattermost']['config']['install_path'] +
                   '/mattermost/bin/mmctl',
                   transformed_key,
                   value)
    # Chef::Log.debug cmd
    execute "Updating #{transformed_key}" do
      command cmd
      user node['mattermost']['config']['user']
    end
  end
end
