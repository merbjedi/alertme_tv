# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can specify conditions on the placeholder by passing a hash as the second
# argument of "match"
#
#   match("/registration/:course_name", :course_name => /^[a-z]{3,5}-\d{5}$/).
#     to(:controller => "registration")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  # RESTful routes
  resources :users do
    collection :profile
    collection :alerts

    collection :account
    collection :favorites
    
    collection :mini_account
    collection :mini_account_update
    collection :mini_favorites
    collection :mini_alerts
    collection :mini_alerts_update
    
    collection :mini_login
    collection :mini_register
    
    collection :mini_counts
  end
  
  resources :alerts do
    collection :set
  end
  
  resources :shows do
    member :tooltip
    member :set_alert
    member :toggle_favorite
    
    collection :dashboard
    collection :search
    collection :add
  end
  
  # test routes
  match('/sliders').to(:controller => 'pages', :action => "sliders")
  match('/sliders1').to(:controller => 'pages', :action => "sliders1")
  match('/sliders2').to(:controller => 'pages', :action => "sliders2")
  match('/sliders3').to(:controller => 'pages', :action => "sliders3")
  
  # registration
  match('/register').to(:controller => 'users', :action => "new")
  
  match('/u/:id').to(:controller => 'users', :action => "show")
  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  default_routes
  
  # Change this for your home page to be available at /
  match('/').to(:controller => AppConfig.landing_controller, :action => AppConfig.landing_action)
  
end