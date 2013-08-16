require 'jekyll-page-hooks'
require 'time'

module Jekyll
  class PageHooksTest < PageHooks

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
      log_page page
    end

    # Plugin methods

    # Replaces *cupcake* with _______ before markdown renders <em>cupcake</em>.
    #
    def snatch_cupcake(content)
      content.sub /\*cupcake\*/, '_______'
    end
    
    # Replaces <strong> tag with <strong><blink> after html has been rendered.
    #
    def blink_strong(content)
      content.gsub /(<strong>.+?<\/strong>)/ do
        "<blink>#{$1}</blink>"
      end
    end

    # Rewrites the generated file on disk, replacing ::time:: with a <time> tag
    # noting when the file was written.
    #
    def log_page(page)
      time = Time.now
      content = page.output.gsub /::time::/ do
        "<time datetime='#{time.utc.iso8601}'>#{time.localtime.strftime('%Y-%m-%d %H:%M:%s')}</time>"
      end
      
      file = page.destination page.site.config['destination']
      File.open(file, 'w') { |f| f.write content }
    end

  end
end
