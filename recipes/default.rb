#
# Cookbook:: mattermost
# Recipe:: default
#
# Copyright:: (c) 2017 The Authors, All Rights Reserved.
install_directory = "#{node['mattermost']['config']['install_path']}/mattermost"

user node['mattermost']['config']['user'] do
  action :create
end

directory install_directory do
  owner node['mattermost']['config']['user']
  group node['mattermost']['config']['group']
  mode '755'
  recursive true
  action :create
end

wanted_version = mm_find_best_version(node['mattermost']['version'])

Chef::Log.debug "Installing mattermost #{wanted_version}, #{node['mattermost']['edition']} edition"

url = node['mattermost']['packages'][node['mattermost']['edition']][wanted_version]['url']
csum = node['mattermost']['packages'][node['mattermost']['edition']][wanted_version]['checksum']

tar_extract url do
  download_dir node['mattermost']['config']['install_path']
  target_dir node['mattermost']['config']['install_path']
  checksum csum
  # user node['mattermost']['config']['user']
  # group node['mattermost']['config']['group']
  creates "#{install_directory}/bin/mattermost"
  action :extract
end

[ node['mattermost']['config']['data_dir'],
  node['mattermost']['app']['file_settings']['directory'],
  "#{install_directory}/#{node['mattermost']['app']['plugin_settings']['directory']}",
  "#{install_directory}/#{node['mattermost']['app']['plugin_settings']['client_directory']}",
  node['mattermost']['app']['log_settings']['file_location'],
  # node['mattermost']['app']['notification_log_settings'],
  ::File.dirname(node['mattermost']['config']['path'])
].each do |dir|

  directory dir do
    owner node['mattermost']['config']['user']
    group node['mattermost']['config']['group']
    mode '0750'
    recursive true
    action :create
  end
end

# # move over pristine config.json from tarball
remote_file node['mattermost']['config']['path'] do
  action :create_if_missing
  source "file:://#{install_directory}/mattermost/config/config.json"
  owner node['mattermost']['config']['user']
  group node['mattermost']['config']['group']
  mode '0640'
  notifies :restart, 'systemd_unit[mattermost.service]'
  not_if do
    # do nothing if config.json is in the default location:
    node['mattermost']['config']['path'] ==
      "#{install_directory}/config/config.json"
  end
end

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

systemd_unit 'mattermost.service' do
  content(
    Unit: {
      Description: 'Mattermost',
      After: node['mattermost']['systemd']['after'].join(' '),
    },
    Service: {
      ExecStart: format("%s/bin/mattermost --config %s",
                        install_directory,
                        node['mattermost']['config']['path']
                       ),
      WorkingDirectory: install_directory,
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
  verify false if respond_to?(:verify)
  action [:create, :enable, :start]
end
