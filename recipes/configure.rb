#
#
#

node['mattermost']['app'].each do |group,settings|
  settings.each do |key, value|
    mattermost_cookbook_config "#{group}.#{key}" do
      value value.to_s
      ignore_failure true
    end
  end
end

#
# database setup (adapted from config.json.erb template)
#
#   "SqlSettings": {
#        "DriverName": "<%= node['mattermost']['app']['sql_settings']['driver_name'] %>",
# replica_count = node['mattermost']['app']['sql_settings']['data_source_replicas'].count
if node['mattermost']['database']['driver_name'] == 'postgres'
  mattermost_cookbook_config  'SqlSettings.DataSource' do
    value format("postgres://%s:%s@%s:%i/%s?sslmode=disable&connect_timeout=10",
                 node['mattermost']['database']['username'],
                 node['mattermost']['database']['password'],
                 node['mattermost']['database']['address'],
                 node['mattermost']['database']['port'],
                 node['mattermost']['database']['name']
                )
  end
    #     "DataSourceReplicas": [
    # <%- node['mattermost']['app']['sql_settings']['data_source_replicas'].each_with_index do |replica, i| %>
    #     <% if (i < ( replica_count - 1 )) %>
    #     <% Chef::Log.info("Iterator is #{i}") %>
    #         "postgres://<%= node['mattermost']['app']['sql_settings']['username'] %>:<%= node['mattermost']['app']['sql_settings']['password'] %>@<%= replica %>:<%= node['mattermost']['app']['sql_settings']['port'] %>/<%= node['mattermost']['app']['sql_settings']['database_name'] %>?sslmode=disable&connect_timeout=10",
    #     <% else %>
    #         "postgres://<%= node['mattermost']['app']['sql_settings']['username'] %>:<%= node['mattermost']['app']['sql_settings']['password'] %>@<%= replica %>:<%= node['mattermost']['app']['sql_settings']['port'] %>/<%= node['mattermost']['app']['sql_settings']['database_name'] %>?sslmode=disable&connect_timeout=10"
    #     <% end %>
    # <%- end %>
    #     ],
else
  # -> mysql
  mattermost_cookbook_config  'SqlSettings.DataSource' do
    value format('%s:%s@tcp(%s:%i)/%s?charset=utf8mb4,utf8;readTimeout=30s;writeTimeout=30s',
                 node['mattermost']['database']['username'],
                 node['mattermost']['database']['password'],
                 node['mattermost']['database']['address'],
                 node['mattermost']['database']['port'],
                 node['mattermost']['database']['name']
                )
  end
end

#   "DataSourceReplicas": [
#   <%- node['mattermost']['app']['sql_settings']['data_source_replicas'].each_with_index do |replica, i| %>
#             <% if (i < ( replica_count - 1 )) %>
#                   "<%= node['mattermost']['app']['sql_settings']['username'] %>:<%= node['mattermost']['app']['sql_settings']['password'] %>@tcp(<%= r  eplica %>:<%= node['mattermost']['app']['sql_settings']['port'] %>)/<%= node['mattermost']['app']['sql_settings']['name'] %>?charset=utf8m  b4,utf8&readTimeout=30s&writeTimeout=30s",
#         <% else   %>
#             "<%= n  ode['mattermost']['app']['sql_settings']['username'] %>:<%= node['mattermost']['app']['sql_settings']['password'] %>@tcp(<%= replica %>:<%  = node['mattermost']['app']['sql_settings']['port'] %>)/<%= node['mattermost']['app']['sql_settings']['name'] %>?charset=utf8mb4,utf8&read  Timeout=30s&writeTimeout=30s"
#         <% end %>
#     <%- end %>
#         ],
# <% end %>
