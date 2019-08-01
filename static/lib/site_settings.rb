# this lib lets you load the mm' application's settings without loading all of
# mm, including encrypted sekrets.  useful for keeping CLI scripts
# fast-loading!

#
  site_settings = Map.new

#
  path = File.join(MM.root, 'config', 'site.yml')

  if test(?e, path)
    site_settings.update(Settings.for(path))
  end

#
  path = File.join(MM.root, 'config', 'site.yml.enc')
  key = File.join(MM.root, '.sekrets.key')

  if test(?e, path)
    unless test(?e, key)
      abort("missing '.sekrets.key' !")
    end

    site_settings[:sekrets] = Sekrets.settings_for(path)
  end

  sekrets = site_settings[:sekrets]

#
  env = MM.env

#
  if site_settings.has?(env)
    env_settings = site_settings.get(env)
    env_settings.depth_first_each do |key, val|
      site_settings.set(key, val)
    end
  end

#
  if sekrets && sekrets.has?(env)
    env_settings = sekrets.get(env)
    env_settings.depth_first_each do |key, val|
      sekrets.set(key, val)
    end
  end

#
  $site_settings = site_settings
  SITE_SETTINGS = site_settings


BEGIN {

# built-in ruby deps
#
  require 'yaml'

# suck Gemfile in
#
  unless defined?(Bundler)
    require 'pathname'
    ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../Gemfile",
      Pathname.new(__FILE__).realpath)
    require 'rubygems'
    require 'bundler/setup'
  end

# require some select libs
#
  require 'map'
  require 'sekrets'

# load env.rb for RAILS_STAGE / RAILS_ENV
#
  dirname = File.dirname(File.expand_path(__FILE__))
  root = File.dirname(dirname)
  load(File.join(root, 'config', 'env.rb'))

# include libdir
#
  $LOAD_PATH.push("#{ root }/lib")
  require 'settings'

# stub MM object in so we can eval the config file(s)
#
  unless defined?(MM)
    module MM
      class StringInquirer < ::String
        def method_missing(method, *args, &block)
          case method.to_s
            when /\A(.*)[?]\Z/
              self == $1
            else
              super
          end
        end
      end

      Fattr(:env)
      Fattr(:stage)
      Fattr(:root)
    end

    MM.root = Pathname.new(root)
    MM.env = MM::StringInquirer.new(ENV['MM_ENV'] || 'development')

    unless defined?(MM_ENV)
      MM_ROOT = MM.root
      MM_ENV = MM.env
    end
  end
}
