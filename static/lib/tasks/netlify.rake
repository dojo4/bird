namespace :netlify do
  task :deploy => :client do
    unless ENV['DEPLOY_SCRIPT']
      STDERR.puts "DON'T USE THIS TASK DIRECTLY - use ./scripts/deploy instead"
      abort
    end

    id = @config.get(:site, :id)
    url = @config.get(:site, :url)

    Say.say("deploying #{ url || id } ...", :color => :yellow)

    site = @client.sites.get(id)
    site.update(:dir => 'deploy')
    site.wait_for_ready

    Say.say("deployed #{ url || id }", :color => :green)
  end

#
  desc 'list sites'
  task :sites => :client do
    report = {}

    @client.sites.each do |site|
      report[site.id] = site.url
    end

    Say.say(report.to_yaml, :color => :green)
  end

#
  desc 'setup netlify client'
  task :client => [:env, :config] do
    @client =
      Netlify::Client.new(
        :access_token => @config.get(:account, :access_token)
      )
    @client.sites.to_a # raises Netlify::Client::AuthenticationError iff not auth'd
  end

#
  desc 'load the environment'
  task :env do
    require 'yaml'

    require_relative '../../config/boot.rb'

    require 'pry'
    require 'map'
    require 'netlify'
  end

#
  desc 'load the config'
  task :config => [:env] do
    @config ||= Site.config.netlify
  end

#
  desc 'info'
  task :info => [:client, :config] do
    require 'pp'
    pp @client
    puts '---'
    pp @config
  end

#
  desc 'setup a new netlify site and save config'
  task :setup => :client do
    Dir.chdir(Site.root) do
      FileUtils.touch './build'
      IO.binwrite './build/index.html', '42'

      site = @client.sites.create(:dir => './build')

      sekrets = Sekrets.settings_for('config/site.yml.enc')

      sekrets.set(:netlify, :site, :id, site.id)
      sekrets.set(:netlify, :site, :url, site.url)

      Sekrets.write('config/site.yml.enc', sekrets.to_hash.to_yaml)
      puts Sekrets.read('config/site.yml.enc')
    end
  end
end
