default_unless['mattermost']['version'] = '5'
default_unless['mattermost']['edition'] = 'team'

default_unless['mattermost']['config']['install_path'] = '/opt'
default_unless['mattermost']['config']['user']         = 'mattermost'
default_unless['mattermost']['config']['group']        = node['mattermost']['config']['user']
default_unless['mattermost']['config']['data_dir']     = '/opt/mattermost/data'
default_unless['mattermost']['config']['server_name']  = 'localhost'

default_unless['mattermost']['config']['path'] =
  node['mattermost']['config']['install_path'] + '/mattermost/config/config.json'

default_unless['mattermost']['systemd']['after'] = %w( syslog.target network.target )
