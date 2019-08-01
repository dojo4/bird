module Site
  fattr(:app)
  fattr(:env){ MM_ENV }
  fattr(:root){ File.dirname(File.dirname(File.expand_path(__FILE__))) }

  def url(*args)
    options = Map.options_for!(args) 

    only_path = options.delete(:only_path) || options.delete(:path_only)
    path_info = options.delete(:path_info) || options.delete(:path)
    query_string = options.delete(:query_string)
    fragment = options.delete(:fragment) || options.delete(:hash)
    query = options.delete(:query) || options.delete(:params)

    raise(ArgumentError, 'both of query and query_string') if query and query_string

    args.push(path_info) if path_info

    path_info = ('/' + args.join('/')).gsub(%r|/+|,'/')

    unless only_path==true
      url = Site.slash + path_info
    else
      url = path_info
    end
    
    url += ('?' + query_string) unless query_string.blank?
    url += ('?' + query.query_string) unless query.blank?
    url += ('#' + fragment) if fragment
    url 
  end

  def Site.slash(*args)
    Site.config.url.to_s.sub(%r|/*$|, '')
  end

  def init(app)
    self.app = app
    self.clean_build_directory_on_start_once!
  end

  def clean_build_directory_on_start_once!
    $clean_build_directory_on_start_once ||= (
      FileUtils.rm_rf("#{ app.root }/build")
      FileUtils.mkdir_p("#{ app.root }/build")
      42 
    ) 
  end

  def config
    @config ||= (
    #
      config = Map.new

    #
      path = File.join(Site.root.to_s, 'config/site.yml')
      if test(?s, path)
        settings = Settings.for(path)
        config.update(settings)
      end

    #
      path = File.join(Site.root.to_s, 'config/site.yml.enc')
      if test(?s, path)
        settings = Sekrets.settings_for(path)
        config.update(:sekrets => settings)
        config.update(settings)
      end

    #
       if config.has_key?(env)
         config.update(config[env])
       end

    #
      config
    )
  end

  extend(Site)
end
