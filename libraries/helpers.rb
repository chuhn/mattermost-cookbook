#
# Cookbook Name:: mattermost-cookbook
# Helper functions
#
# Copyright 2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
# turn the database connection params into a connection string
#
def format_dsn(driver: node['mattermost']['app']['sql_settings']['driver_name'],
               username: node['mattermost']['database']['username'],
               password: node['mattermost']['database']['password'],
               hostname: node['mattermost']['database']['address'],
               port: node['mattermost']['database']['port'],
               db: node['mattermost']['database']['name'])

  format = case driver.to_s
           when 'postgres'
             # FIXME: why do we turn off SSL unconditionally here?
             #  Does not seem like a good idea
             'postgres://%s:%s@%s:%i/%s?sslmode=disable&connect_timeout=10'
           when 'mysql'
             '%s:%s@tcp(%s:%i)/%s?charset=utf8mb4,utf8;readTimeout=30s;writeTimeout=30s'
           else
             raise 'Only postgres and mysql are supported'
           end
  format(format, username, password, hostname, port, db)
end


#
# gather mattermost version information
#
def mm_version_info
  cmd = format('%s --config "%s" version',
               node['mattermost']['config']['install_path'] +
               '/mattermost/bin/mattermost',
               node['mattermost']['config']['path'])
  version_query = Mixlib::ShellOut.new(cmd)
  # TODO: add some better error handling?
  version_query.error!
  version_query.stdout.scan(%r{(.*?):(.*)}).to_h
end
