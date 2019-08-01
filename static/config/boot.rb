# encoding: utf-8

# start with the project's environment
#
  require_relative 'env.rb'

# bundle setup
#
  require 'rubygems'

  ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

  require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

  Bundler.setup(:require => false)

# include the project's libdir in $LOAD_PATH
#
  config_dir = File.expand_path(File.dirname(__FILE__))
  root = File.dirname(config_dir)
  lib_dir = File.join(root, "lib")

  $LOAD_PATH.unshift(lib_dir)

# setup MM_ROOT
#
  config_dir = File.expand_path(File.dirname(__FILE__))
  mm_root = File.dirname(config_dir)
  mm_env = ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development'

  MM = mm_root.dup

  MM_ROOT = mm_root.dup
  ENV['MM_ROOT'] = MM_ROOT

  MM_ENV = mm_env.dup
  ENV['MM_ENV'] = MM_ENV

  require 'fattr'

  class << MM_ENV
    def method_missing(method, *args, &block)
      method = method.to_s
      if method =~ /(.*)[?]/
        return self == $1
      else
        super
      end
    end
  end

  class << MM
    fattr(:env){ MM_ENV }
    fattr(:root){ MM_ROOT }
  end

# deps
#
#
  require "pry"
  require "redcarpet"
  require "rb-pygments"
  require "map"
  require "fattr"
  require "sekrets"

  config_dir = File.expand_path(File.dirname(__FILE__))
  root = File.dirname(config_dir)

  require "#{ root }/lib/slug"
  require "#{ root }/lib/uuid"
  require "#{ root }/lib/util"
  require "#{ root }/lib/say"
  require "#{ root }/lib/helpers"
  require "#{ root }/lib/settings"
  require "#{ root }/lib/site"
