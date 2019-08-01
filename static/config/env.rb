# encoding: utf-8
 
# start with a fresh environment
#
  keys = %w[ GEM_PATH GEM_HOME BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT RUBYLIB ]

  env = {}

  keys.each do |key|
    env[key] = ENV.delete(key)
  end

# fold in any local env config
#
  config_dir = File.dirname(__FILE__)
  config_yml = File.join(config_dir, 'env.yml')
  if test(?s, config_yml)
    require 'yaml'
    env = YAML.load(IO.binread(config_yml))
    env.each do |key, val|
      ENV[key.to_s] = val.to_s
    end
  end
