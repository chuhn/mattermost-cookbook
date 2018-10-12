#
# Cookbook Name:: mattermost
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.
apt_package 'libcap2-bin' if node['platform_family'] == 'debian'

user node['mattermost']['config']['user'] do
  action :create
end

directory "#{node['mattermost']['config']['install_path']}/mattermost" do
  owner node['mattermost']['config']['user']
  group node['mattermost']['config']['user']
  mode 0755
  recursive true
  action :create
end

tar_extract node['mattermost']['package']['url'] do
  download_dir node['mattermost']['config']['install_path']
  target_dir node['mattermost']['config']['install_path']
  checksum node['mattermost']['package']['checksum']
  user node['mattermost']['config']['user']
  group node['mattermost']['config']['user']
  creates "#{node['mattermost']['config']['install_path']}/mattermost/config"
  action :extract
end

directory node['mattermost']['config']['data_dir'] do
  owner node['mattermost']['config']['user']
  group node['mattermost']['config']['user']
  mode 0755
  recursive true
  action :create
end

directory "#{node['mattermost']['config']['install_path']}/#{node['mattermost']['app']['plugin_settings']['client_directory']}" do
  owner node['mattermost']['config']['user']
  group node['mattermost']['config']['user']
  mode 0755
  recursive true
  action :create
end

template "#{node['mattermost']['config']['install_path']}/mattermost/config/config.json" do
  source 'config.json.erb'
  owner node['mattermost']['config']['user']
  group node['mattermost']['config']['user']
  mode '0640'
  notifies :restart, 'systemd_unit[mattermost.service]'
end

execute 'setcap cap_net_bind_service=+ep ./platform' do
  cwd "#{node['mattermost']['config']['install_path']}/mattermost/bin"
  user 'root'
end

systemd_unit 'mattermost.service' do
  content(
    Unit: {
      Description: 'Mattermost',
      After: node['mattermost']['systemd']['after'].join(' '),
    },
    Service: {
      ExecStart: "#{node['mattermost']['config']['install_path']}/mattermost/bin/mattermost",
      WorkingDirectory: "#{node['mattermost']['config']['install_path']}/mattermost",
      Restart: 'always',
      StandardOutput: 'syslog',
      StandardError: 'syslog',
      SyslogIdentifier: 'mattermost',
      User: node['mattermost']['config']['user'].to_s,
      Group: node['mattermost']['config']['group'].to_s,
    },
    Install: {
      WantedBy: 'multi-user.target',
    }
  )
  verify false
  action [:create, :enable, :start]
end
