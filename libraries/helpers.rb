

def format_dsn(driver: node['mattermost']['database']['driver_name'],
               username: node['mattermost']['database']['username'],
               password: node['mattermost']['database']['password'],
               hostname: node['mattermost']['database']['address'],
               port: node['mattermost']['database']['port'],
               db: node['mattermost']['database']['name'])
  format = case driver
           when 'postgres'
             'postgres://%s:%s@%s:%i/%s?sslmode=disable&connect_timeout=10'
           when 'mysql'
             '%s:%s@tcp(%s:%i)/%s?charset=utf8mb4,utf8;readTimeout=30s;writeTimeout=30s'
           else
             raise 'Only postgres and mysql are supported'
           end
  format(format, username, password, hostname, port, db)
end
