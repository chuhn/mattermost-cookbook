require 'spec_helper'

describe 'mattermost-cookbook::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe) }

  it 'creates user mattermost' do
    expect(chef_run).to create_user('mattermost')
  end

  it 'downloads and extracts' do
    expect(chef_run).to extract_tar_extract('https://releases.mattermost.com/5.13.3/mattermost-5.13.3-linux-amd64.tar.gz').with(
      checksum: '41f40fb7397309aeecdd9c8670e8f137a4892093ec658fc0346c732bca54e8f9',
      target_dir: '/opt',
      user: 'mattermost',
      group: 'mattermost'
    )
  end

  it 'creates data directory ' do
    expect(chef_run).to create_directory('/opt/mattermost/data').with(
      user: 'mattermost',
      mode: 0755,
      recursive: true
    )
  end

  it 'creates plugins directory ' do
    expect(chef_run).to create_directory('/opt/mattermost/client/plugins').with(
      user: 'mattermost',
      mode: 0755,
      recursive: true
    )
  end

  it 'creates mattermost config template' do
    expect(chef_run).to create_template('/opt/mattermost/config/config.json')
  end

  it 'enables and starts mattermost service' do
    expect(chef_run).to create_systemd_unit('mattermost.service')
    expect(chef_run).to enable_systemd_unit('mattermost.service')
    expect(chef_run).to start_systemd_unit('mattermost.service')
  end
end
