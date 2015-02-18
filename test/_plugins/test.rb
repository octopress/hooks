require File.expand_path('../../../lib/octopress-hooks.rb', __FILE__)

@kill_reset = true

module TestingHooks
  class SiteHookTest < Octopress::Hooks::Site
    def pre_read(site)
      file = File.join(site.source, 'pre_read')
      File.open(file, 'w') { |f| f.write("pages: #{site.pages.size}") }
      abort 'Reset failed' if @kill_reset
    end

    def reset(site)
      @kill_reset = false
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

  class DocHooksTest < Octopress::Hooks::Document

    def post_init(doc)
      doc.data['injected_data'] = 'Ok?'
    end

    # Called after processors
    # 
    def post_render(doc)
      doc.output = blink_strong doc.output
    end

    def blink_strong(content)
      content.gsub /(<strong>.+?<\/strong>)/ do
        "<blink>#{$1}</blink>"
      end
    end
  end

  class AllHooksTest < Octopress::Hooks::All
    def post_init(item)
      item.data['hooked'] = 'yep'
    end

    def merge_payload(payload, page)
      page.data['payload']
    end

    def post_render(item)
      item.output.gsub!('cookies', 'brownies')
    end

    def post_write(item)
      file = Pathname.new(item.destination(item.site.config['destination']))
      path = file.relative_path_from(Pathname.new(item.site.source))
      File.open("_site/writelog", 'a') { |f| f.write("#{path}\n") }
    end

  end

  class PageHooksTest < Octopress::Hooks::Page

    # Inherited methods from PageHooks
   
    # Called before processors
    # 
    def pre_render(page)
      page.content = snatch_cupcake page.content
    end

    def post_init(page)
      page.data['injected_data'] = 'Ok?'
    end


    # Called after processors
    # 
    def post_render(page)
      page.output = blink_strong page.output
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
      content.gsub! /(<strong>.+?<\/strong>)/ do
        "<blink>#{$1}</blink>"
      end
    end
  end
end
