module Helpers
# Sets the html class to 'active' when the link url is equal to the current page being viewed.
# Use just like the link_to helper.
# <%= active_link_to 'Home', '/index.html' %>
#
  def active_link_to(link, url, opts={})
    opts_class = opts[:class] ||= ""
    current_url = current_resource.url
    current_parent_url = current_page.parent.url.to_s rescue ''

    re = %r'^#{ Regexp.escape(url_for(url)) }/*'

    if(
      current_url =~ re || current_parent_url =~ re
    )
        opts[:class] = opts_class + " active"
    end

    link_to(link, url, opts)
  end

# Stolen from Rails docs
# File actionpack/lib/action_view/helpers/url_helper.rb, line 378
#
  def link_to_unless(condition, name, options = {}, html_options = {}, &block)
    if condition
      if block_given?
        block.arity <= 1 ? capture(name, &block) : capture(name, options, html_options, &block)
      else
        ERB::Util.html_escape(name)
      end
    else
      link_to(name, options, html_options)
    end
  end

# og :image => image_path('og.png'), :description => 'site description
#
  def og(*args, &block)
    options = Map.options_for(args)

    tagz {
      options.each do |name, value|
        name = name.to_s

        unless name =~ /^og:/
          name = "og:#{ name }"
        end

        content = Array(value).join(', ')

        meta_(:property => name, :content => content)
        __
      end
    }
  end

#
  require 'tagz'
  include Tagz

#
  def excerpt(*args, &block)
    ::Util.excerpt(*args, &block)
  end

  def page_data(*args, &block)
    unless defined?(@page_data)
      @page_data = Map.new
    end

    if args.empty? and block.nil?
      @page_data
    else
      @page_data.set(*args, &block)
    end
  end

  def page_title(*args, &block)
    unless args.empty?
      page_data.title = args.first.to_s
    end

    title =
      case
        when defined?(@title)
          @title

        when page_data.has_key?(:title)
          page_data.get(:title)

        when defined?(@content)
          case
            when @content.respond_to?(:title)
              @content.title
            when @content.respond_to?(:slug)
              @content.slug.titleize
            else
              nil
          end

        else
          nil
      end

    if title.to_s.strip.tr('/', '').empty?
      title =
        begin
          ::Util.paths_for(current_page.url).map(&:titleize).join(' | ')
        rescue Object
          nil
        end
    end

    [Site.config.title, title].compact.select{|part| !part.to_s.strip.empty?}.join(' | ')
  end

  def page_image
    if @content
      assets = @content.assets
      image  = assets.select{|asset| asset =~ /(jpg|jpeg|tif|gif|png)$/i}.sort.first

      author = @content.respond_to?(:author) ? @content.author : Site.config.author 

      img_path =
        case
          when image
            @content.url_for(image)
          when author && author.respond_to?(:gravatar)
            author.gravatar
          else
            "/images/og.png"
        end

      Site.url(img_path).gsub(/\.gif$/, '.jpg')
    else
      Site.url("/images/og.png")
    end
  end
end
