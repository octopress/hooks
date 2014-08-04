require 'octopress-hooks'

module TestingHooks
  class SiteHookTest < Octopress::Hooks::Site
    def pre_read(site)
      file = File.join(site.source, 'pre_read')
      File.open(file, 'w') { |f| f.write("pages: #{site.pages.size}") }
    end

    def post_read(site)
      file = File.join(site.source, 'post_read')
      File.open(file, 'w') { |f| f.write("pages: #{site.pages.size}") }
    end

    def pre_render(site)
      file = File.join(site.source, 'magic')
      File.open(file, 'w') { |f| f.write('MAGIC') }
      site.static_files << Jekyll::StaticFile.new(site, site.source, '', 'magic')
    end

    def merge_payload(payload, site)
      if payload['site']['title']
        payload['site']['name'] ||= payload['site']['title']
      end

      payload
    end

    def post_write(site)
      file = File.join(site.config['destination'], 'boom')
      File.open(file, 'w') { |f| f.write('BOOM') }
      FileUtils.rm('magic')
    end
  end

  class PostHooksTest < Octopress::Hooks::Post
    def post_init(post)
      post.data['injected_data'] = 'awesome'
    end
  end

  class PageHooksTest < Octopress::Hooks::Page

    # Inherited methods from PageHooks
   
    # Called before processors
    # 
    def pre_render(page)
      page.content = snatch_cupcake page.content
    end

    # Called after processors
    # 
    def post_render(page)
      page.content = blink_strong page.content
    end

    # Called after write
    # 
    def post_write(page)
      file = page.destination(page.site.config['destination'])
      File.open(file, 'w') { |f| f.write(log_write(page.content)) }
    end

    # Plugin methods

    # Replaces *cupcake* with _______ before markdown renders <em>cupcake</em>.
    #
    def snatch_cupcake(content)
      content.sub /\*cupcake\*/, '_______'
    end

    def log_write(content)
      content.sub /hasn&#39;t/, 'has'
    end
    
    # Replaces <strong> tag with <strong><blink> after html has been rendered.
    #
    def blink_strong(content)
      content.gsub /(<strong>.+?<\/strong>)/ do
        "<blink>#{$1}</blink>"
      end
    end
  end
end
