default['mattermost']['version'] = '5'
default['mattermost']['edition'] = 'team'

default['mattermost']['config']['install_path'] = '/opt'
default['mattermost']['config']['user']         = 'mattermost'
default['mattermost']['config']['group']        = node['mattermost']['config']['user']
default['mattermost']['config']['data_dir']     = '/opt/mattermost/data'
default['mattermost']['config']['server_name']  = 'localhost'

default['mattermost']['config']['path'] =
  node['mattermost']['config']['install_path'] + '/mattermost/config/config.json'

default['mattermost']['systemd']['after'] = %w( syslog.target network.target )
