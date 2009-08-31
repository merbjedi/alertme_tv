# Hack for top-level name clash between vlad and datamapper.
if Rake.application.options.show_tasks or Rake.application.top_level_tasks.any? {|t| t == 'deploy' or t =~ /^vlad:/}
  begin
    $TESTING = true # Required to bypass check for reserved_name? in vlad. DataMapper 0.9.x defines Kernel#repository...
    require 'hoe'
    require 'vlad'
    Vlad.load :scm => "git", :app => :passenger, :web => :apache
  rescue LoadError
    # do nothing
  end
end