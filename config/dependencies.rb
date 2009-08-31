# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "1.0.12"
dm_gems_version   = "0.9.11"
do_gems_version   = "0.9.11"

# haml & compass support
dependency "haml", "~> 2.2.0", :require_as => "haml"

dependency "builder", "2.1.2"
dependency "markaby"

# For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
dependency "merb-core", merb_gems_version 
dependency "merb-action-args", merb_gems_version
dependency "merb-assets", merb_gems_version  
dependency("merb-cache", merb_gems_version) do
  Merb::Cache.setup do
    register(Merb::Cache::FileStore) unless Merb.cache
  end
end
dependency "merb-helpers", merb_gems_version 
dependency "merb-mailer", merb_gems_version  
dependency "merb-slices", merb_gems_version  
dependency "merb-auth-core", merb_gems_version
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version
dependency "merb-param-protection", merb_gems_version
dependency "merb-exceptions", merb_gems_version

dependency "data_objects", do_gems_version
dependency "do_mysql", do_gems_version # If using another database, replace this
dependency "dm-core", dm_gems_version         
dependency "dm-aggregates", dm_gems_version   
dependency "dm-migrations", dm_gems_version   
dependency "dm-timestamps", dm_gems_version   
dependency "dm-types", dm_gems_version        
dependency "dm-validations", dm_gems_version  
dependency "dm-serializer", dm_gems_version   

dependency "merb-haml", merb_gems_version
dependency "merb_datamapper", merb_gems_version

# dm-more plugins
dependency "dm-is-list", dm_gems_version
dependency "dm-is-state_machine", dm_gems_version

# more datamapper plugins
dependency "dm-paperclip", ">= 2.1.4"
dependency "dm-counter-cache", ">= 0.9.8"

# compass
dependency "compass", "~> 0.8.5"
dependency "compass-960-plugin", "~> 0.9.7", :require_as => "ninesixty"

# redcloth
dependency "RedCloth", :require_as => "redcloth"

# awesome merb plugins
dependency "merb_has_flash", ">= 1.0"
dependency "merb_app_config", ">= 1.0.7"
dependency "merb_viewfu", ">= 0.3.3"
dependency "merb_form_fields", ">= 0.0.5"
dependency "merb_seed", ">= 0.1.1"

# for paging
dependency "merb_paginate", "0.9.0", :require_as => "will_paginate"

# auth extensions
dependency "merb-auth-slice-password-reset", ">= 0.9.12"
dependency "merb-auth-remember-me", ">= 0.1.0"

# for rest call
dependency "rest-client", ">= 1.0.3", :require_as => "rest_client"

# for xml parsing: http://railstips.org/2009/4/1/crack-the-easiest-way-to-parse-xml-and-json
dependency "httparty", "0.4.4", :require_as => 'httparty'
dependency "jnunemaker-crack", "0.1.3", :require_as => 'crack'

# gem tools
dependency "merb-gen", merb_gems_version, :require_as => nil
dependency 'highline', :require_as => nil
dependency 'thor', :require_as => nil
dependency "vlad", :require_as => nil
dependency 'nokogiri', :require_as => nil
dependency 'webrat', :require_as => nil
dependency "hoe", :require_as => nil
