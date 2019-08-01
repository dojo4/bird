namespace(:site) do
#
  desc "create a new site based on this one"
  task :new do |task, options|
    require 'bundler'

    args = ARGV.map{|arg| "#{ arg }"}

    task_name = args.shift

    options.with_defaults(
      :dst => (ENV['dst'] || ENV['DST'] || args.pop)
    )

    dst = options[:dst].to_s.strip
    abort "no dst" if dst.empty?

    if test(?e, dst)
      abort "#{ dst } exists!" 
    end

    dst = sync(dst)

    identifier = File.basename(dst)

    spawn = proc do |cmd|
      system(cmd) || abort("#{ cmd } # failed with #{ $?.inspect }")
    end

    Dir.chdir(dst) do
      Bundler.with_clean_env do
      #
        spawn[ "bundle install" ]

      #
        spawn[ "./bin/sekrets recrypt config/site.yml.enc -k '^static$' -k '^#{ identifier }$'" ]
        IO.binwrite(".sekrets.key", "^#{ identifier }$")

      #
        require './config/boot.rb'

        config_site = Settings.for('./config/site.yml')

        config_site.update(
          :identifier => identifier,
          :title      => identifier.capitalize,
          :slug       => Slug.for(identifier, :join => '-'),
          :name       => Slug.for(identifier, :join => '_'),

          :description => "a #{ identifier } site",

          :keywords => %W[a #{ identifier } site],

          :author => "DOJO4",

          :development => {
            :url => "http://localhost:4567" 
          },

          :staging => {
            :url => "https://staging-#{ identifier }.com" 
          },

          :production => {
            :url => "https://#{ identifier }.com" 
          }
        )

        IO.binwrite('config/site.yml', config_site.to_hash.to_yaml)

      #
        Bundler.with_clean_env do
          spawn[ "./bin/rake netlify:setup" ]
        end

      #
        `rm -rf ./deploy/ ./build/`
      end
    end
  end

#
  desc "sync an site based on the current state of this one"
  task :sync do |task, options|
    args = ARGV.map{|arg| "#{ arg }"}

    task_name = args.shift

    options.with_defaults(
      :dst => (ENV['dst'] || ENV['DST'] || args.pop)
    )

    dst = options[:dst].to_s.strip
    abort "no dst" if dst.empty?

    sync(dst)
  end


#
  def sync(dst)
    this = File.expand_path(__FILE__)
    task_dir = File.dirname(this)
    lib_dir = File.dirname(task_dir)
    rails_root = File.dirname(lib_dir)

    src = rails_root
    dst = File.expand_path(dst)

    FileUtils.mkdir_p(File.dirname(dst))

    #command = "rsync -avuzb --exclude '.git' --exclude 'vendor/bundle/' --exclude 'tmp' --exclude 'log' #{ src }/ #{ dst }/"
    command = "rsync -avuzb --exclude '.sekrets.key' --exclude '.git' --exclude 'tmp' --exclude 'log' #{ src }/ #{ dst }/"
    system(command)
    dst
  end
end
