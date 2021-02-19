
current_version = mm_version_info['Build Number']

wanted_version = mm_find_best_version(node['mattermost']['version'])

return if current_version == wanted_version

execute 'systemctl stop mattermost'

url = node['mattermost']['packages'][node['mattermost']['edition']][wanted_version]['url']
checksum = node['mattermost']['packages'][node['mattermost']['edition']][wanted_version]['checksum']

directory "node['mattermost']['config']['install_path']/mattermost" do
  action :delete
end

tar_extract "mattermost upgrade #{current_version} ->  #{wanted_version}"  do
  source url
  download_dir node['mattermost']['config']['install_path']
  target_dir node['mattermost']['config']['install_path']
  checksum checksum
  # user node['mattermost']['config']['user']
  # group node['mattermost']['config']['user']
  action :extract
end

execute 'systemctl start mattermost'
