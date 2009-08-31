# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '__PUT__KEY__HERE'  # required for cookie session store
  c[:session_id_key] = '_alertme_tv_session_id' # cookie session id key, defaults to "_session_id"
end

Merb::BootLoader.before_app_loads do
  
  # add hacks
  Dir["#{Merb.root}/merb/hacks/**/*.rb"].sort.each do |initializer|
    require(initializer)
  end
  
  # use public/sass folder to store sass templates
  Merb::Plugins.config[:sass] = {
    :template_location => {"#{Merb.root}/public/sass" => "#{Merb.root}/public/stylesheets"}
  }
  
  # set pagination defaults
  Merb::Plugins.config[:paginate] ||= {}
  
  Merb::Plugins.config[:compass] = {
    :stylesheets => "public/sass",
    :compiled_stylesheets => "public/stylesheets"
  }
  
  Merb::Plugins.config[:viewfu][:headliner] = false
  
end
 
# Merb::BootLoader.after_app_loads do
# 
# end
