namespace :sass do
  desc "Compiles all sass files into CSS"
  task :compile do
    gem 'haml'
    require 'sass'
    puts "*** Updating stylesheets"
    Sass::Plugin.options = Merb::Plugins.config[:sass] if Merb::Plugins.config[:sass]
    Compass.setup_template_location
    Sass::Plugin.update_stylesheets
    puts "*** Done"      
  end
end