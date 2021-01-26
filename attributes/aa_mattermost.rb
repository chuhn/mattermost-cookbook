default['mattermost']['package'] = {
  'url' => 'https://releases.mattermost.com/5.17.1/mattermost-5.17.1-linux-amd64.tar.gz',
  'checksum' => '2da727da93b0d193eb3dfdfadb2534eb43dbbf68bce84074d3cc89619bb8f263',
}

default['mattermost']['config']['install_path'] = '/opt'
default['mattermost']['config']['user']         = 'mattermost'
default['mattermost']['config']['group']        = node['mattermost']['config']['user']
default['mattermost']['config']['data_dir']     = '/opt/mattermost/data'
default['mattermost']['config']['server_name']  = 'localhost'

default['mattermost']['config']['path'] =
  node['mattermost']['config']['install_path'] + '/mattermost/config/config.json'

default['mattermost']['systemd']['after'] = %w( syslog.target network.target )
