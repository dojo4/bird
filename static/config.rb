#
  set :css_dir, 'stylesheets'
  set :js_dir, 'javascripts'
  set :images_dir, 'images'

  # Build-specific configuration
  configure :build do
    # activate :minify_css
    # activate :minify_javascript
    # activate :asset_hash
    # activate :relative_assets
    # set :http_prefix, "/Content/images/"
  end

  activate :directory_indexes
    
  page "/404.html", :directory_index => false
  page "/500.html", :directory_index => false
  page "/robots.txt", :directory_index => false, :layout => false

#
  require "#{ root }/config/boot"

#
  helpers Helpers

#
  Site.init($app = self)
