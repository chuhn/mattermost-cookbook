#
# lightweight resource to tweak the mattermost config
#

property :name, String, name_attribute: true
property :value, String

# attribute names in this cookbook have been transformed
#  from CamelCase to snake_case
#  make a guess at converting it back:
def transform_key(name)
  # this is like &capitalize but it keeps the case of the following characters:
  name.split('_').map{|e| e[0].upcase + e[1..-1]}.join
end

def configured?(name_elements, value)
  config = JSON.parse(::File.read(node['mattermost']['config']['install_path'] +
                                  '/mattermost/config/config.json'))
  name_elements.each do |key|
    return false unless config.key?(key)
    config = config[key]
  end
  config == value
end

action :set do
  transformed_key = name.split('.').map{|e| transform_key(e)}
  execute node['mattermost']['config']['install_path'] +
          "/mattermost/bin/mattermost config set " +
          "'#{transformed_key.join('.')}' '#{value}'" do
    user   node['mattermost']['config']['user']
    not_if { configured?(transformed_key, value) }
  end
end
