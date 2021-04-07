
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
# lightweight resource to tweak the mattermost config
#

property :name, String, name_attribute: true
property :value, [String, TrueClass, FalseClass], coerce: proc {|v| v.to_s}
property :config_json, String, default: node['mattermost']['config']['path']

# attribute names in this cookbook have been transformed
#  from CamelCase to snake_case
#  make a guess at converting it back:
def transform_key(name)
  # this is like &capitalize but it keeps the case of the following characters:
  name.split('_').map{|e| e[0].upcase + e[1..-1]}.join
end

load_current_value do |new_resource|
  config = JSON.parse(::File.read(new_resource.config_json))
  new_resource.name.split('.').each do |key|
    tkey = transform_key(key)
    return unless config.key?(tkey)
    config = config[tkey]
  end
  value config.to_s
end

action :set do
  converge_if_changed do
    transformed_key = new_resource.name.split('.').map{|e| transform_key(e)}.join('.')

    service 'mattermost' do
      action :nothing
    end

    cmd = format('%s --config "%s" config set "%s" "%s"',
                   node['mattermost']['config']['install_path'] +
                   '/mattermost/bin/mattermost',
                   new_resource.config_json,
                   transformed_key,
                   new_resource.value)
    # Chef::Log.debug cmd
    execute "Updating #{transformed_key}" do
      command cmd
      user node['mattermost']['config']['user']
      # mattermost must not run while the config
      notifies :stop, 'service[mattermost]', :before
      # restart will be handled by service resource in default recipe
      # notifies :start,  'service[mattermost]'
    end
  end
end
