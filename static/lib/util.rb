module Util
  class SyntaxHighlighting < Redcarpet::Render::HTML
    def block_code(code, language)
      language = 'ruby' if language.to_s.strip.empty?
      Pygments.highlight(code, :lexer => language, :options => {:encoding => 'utf-8'})
    end
  end
 
  def markdown(*args, &block)
    @markdown ||=
      Redcarpet::Markdown.new(
        SyntaxHighlighting,
    
        :no_intra_emphasis            => true,
        :tables                       => true,
        :fenced_code_blocks           => true,
        :autolink                     => true,
        :disable_indented_code_blocks => true,
        :strikethrough                => true,
        :lax_spacing                  => true,
        :space_after_headers          => false,
        :superscript                  => true,
        :underline                    => true,
        :highlight                    => true,
        :quote                        => true,

        :hard_wrap                    => true,
        :with_toc_data                => true,
        :nesting_level                => 2
      )

    if args.empty? and block.nil?
      @markdown
    else
      source = args.join
      return nil if source.to_s.strip.empty?
      @markdown.render(source, &block).strip.sub(/\A<p>/,'').sub(/<\/p>\Z/,'')
    end
  end

  def directory_signature(directory)
    directory = File.expand_path(directory.to_s)

    glob = File.join(directory, '**/**')

    signature = []

    Dir.glob(glob) do |entry|
      #begin
        stat = File.stat(entry)
        timestamp = stat.mtime.to_f
        relative = Util.relative_path(entry, :from => directory)
        signature.push("#{ relative }@#{ timestamp }")
      #rescue
      #end
    end

    md5(signature.join(','))
  end

  require 'digest/md5'

  def md5(data)
    Digest::MD5.hexdigest(data)
  end

  def paths_for(*args)
    path = args.flatten.compact.join('/')
    path.gsub!(%r|[.]+/|, '/')
    path.squeeze!('/')
    path.sub!(%r|^/|, '')
    path.sub!(%r|/$|, '')
    paths = path.split('/')
  end

  def absolute_path_for(*args)
    path = ('/' + paths_for(*args).join('/')).squeeze('/')
    path unless path.blank?
  end

  def relative_path_for(*args)
    path = absolute_path_for(*args).sub(%r{^/+}, '')
    path unless path.blank?
  end
    
  def normalize_path(arg, *args)
    absolute_path_for(arg, *args)
  end

  def relative_path(path, *args)
    options = Map.options_for!(args)
    path = String(path)
    relative = args.shift || options[:relative] || options[:to] || options[:from]

    if relative
      Pathname.new(path).relative_path_from(Pathname.new(relative.to_s)).to_s
    else
      relative_path_for(path)
    end
  end

  require 'securerandom' unless defined?(SecureRandom)

  def uuid
    SecureRandom.uuid
  end

  def domid
    uuid
  end

  def unindented!(s)
    margin = nil
    s.each_line do |line|
      next if line =~ %r/^\s*$/
      margin = line[%r/^\s*/] and break
    end
    s.gsub! %r/^#{ margin }/, "" if margin
    margin ? s : nil
  end

  def unindented s
    s = "#{ s }"
    unindented! s
    s
  end

  def indented!(s, n = 2)
    margin = ' ' * Integer(n)
    unindented!(s).to_s.gsub!(%r/^/, margin)
    s
  end

  def indented(s, n = 2)
    s = "#{ s }"
    indented! s, n
    s
  end

  alias_method('indent', 'indented')

  def code_excerpt
    code =
      <<-__
        ```ruby

          class Dojo4

            @@code_reading_ahead =
              :YAY!

          end

        ```
      __

    Util.markdown(Util.unindented(code))
  end

  def gist_excerpt(src)
    uri = URI.parse(src.to_s)

    host = uri.host
    path = uri.path

    code =
      <<-__
        ```ruby

          class Gist

            @@gist =
              #{ [host, path].compact.join.inspect }

          end

        ```
      __

    Util.markdown(Util.unindented(code))
  end

  def excerpt(html, *args)
  #
    options = args.last.is_a?(Hash) ? args.pop : {}

    html = [html.to_s, *args].join(' ')

  # ensure code samples aren't stupidly long in excerpts
  # 
    doc = ::Nokogiri::HTML::DocumentFragment.parse(html)

    doc.traverse do |node|
      case
        when node.name == 'div' && node.attr('class') == 'highlight'
          node.replace(code_excerpt)

        when node.name == 'script' && node.attr('src').to_s =~ /gist\.github\.com/
          node.replace(gist_excerpt(node.attr('src')))
      end
    end

  #
    html = doc.to_html

    unless options.has_key?(:strip_html)
      options[:strip_html] = false
    end

    unless options.has_key?(:paragraphs)
      options[:paragraphs] = 3
    end

    AutoExcerpt.new(html, options)
  end

  extend(Util)
end
