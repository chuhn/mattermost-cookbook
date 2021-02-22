#
# Cookbook:: mattermost
# Recipe:: default
#
# Copyright:: (c) 2017 The Authors, All Rights Reserved.

# configure stuff:
include_recipe 'mattermost-cookbook::configure'

# if the mattermost server shall bind to a privileged port
#  we have to set the CAP_NET_BIND_SERVICE capability
mattermost_port = node['mattermost']['app']['service_settings']['listen_address'].match(/.*:(\d+)$/)[1].to_i

if mattermost_port < 1024
  apt_package 'libcap2-bin' if platform_family?('debian')

  execute "setcap cap_net_bind_service=+ep #{install_directory}/bin/platform" do
    user 'root'
  end
end

service 'mattermost' do
  # service_name 'mattermost-server'
  action %i[enable start]
end
