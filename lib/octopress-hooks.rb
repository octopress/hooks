require 'octopress-hooks/version'
require 'jekyll'

module Octopress  
  module Hooks
    
    # Extended plugin type that allows the plugin
    # to be called on varous callback methods.
    #
    class Page < Jekyll::Plugin

      # Called before post is sent to the converter. Allows
      # you to modify the post object before the converter
      # does it's thing
      #
      def pre_render(post)
      end

      # Called after the post is rendered with the converter.
      # Use the post object to modify it's contents before the
      # post is inserted into the template.
      #
      def post_render(post)
      end

      # Called after the post is written to the disk.
      # Use the post object to read it's contents to do something
      # after the post is safely written.
      #
      def post_write(post)
      end
    end

    class Site < Jekyll::Plugin

      # Called before Jekyll renders posts and pages
      # Returns nothing
      # 
      def pre_render(site)
      end

      # Merges hash into site_payload
      # Returns hash to be merged
      #
      def merge_payload(payload, site)
        payload
      end

      # Called after Jekyll writes site files
      # Returns nothing
      #
      def post_write(site)
      end

    end
  end
end

# Monkey-patch Jekyll to add triggers for hooks

module Jekyll

  # For compatibilty with old jekyll-page-hooks gem
  #
  PageHooks = Class.new(Octopress::Hooks::Page)

  # Monkey patch for the Jekyll Site class.
  class Site

    # Instance variable to store the various page_hook
    # plugins that are loaded.
    attr_accessor :page_hooks, :site_hooks

    # Instantiates all of the hook plugins. This is basically
    # a duplication of the other loaders in Site#setup.
    def load_hooks
      self.site_hooks = instantiate_subclasses(Octopress::Hooks::Site)
      self.page_hooks = instantiate_subclasses(Octopress::Hooks::Page)
    end


    alias_method :old_site_payload, :site_payload
    alias_method :old_render, :render
    alias_method :old_write, :write

    # Allows site hooks to get access to the site before
    # the render method is called
    #
    # Returns nothing
    def render
      self.load_hooks

      if self.site_hooks
        self.site_hooks.each do |hook|
          hook.pre_render(self)
        end
      end

      old_render
    end

    # Allows site hooks to merge data into the site payload
    #
    # Returns the patched site payload
    def site_payload
      unless @cached_payload
        payload = old_site_payload

        if self.site_hooks
          self.site_hooks.each do |hook|
            p = hook.merge_payload(payload, self) || {}
            if p != {}
              payload = Jekyll::Utils.deep_merge_hashes(payload, p)
            end
          end
        end

        @cached_payload = payload
      end

      @cached_payload
    end

    # Trigger site hooks after site has been written
    #
    # Returns nothing
    def write
      old_write
    
      if self.site_hooks
        self.site_hooks.each do |hook|
          hook.post_write(self)
        end
      end
    end

  end


  # Create a new page class to allow partials to trigger Jekyll Page Hooks.
  #
  class ConvertiblePartial
    include Convertible
    
    attr_accessor :name, :content, :site, :ext, :output, :data
    
    def initialize(site, name, content)
      @site     = site
      @name     = name
      @ext      = File.extname(name)
      @content  = content
      @data     = { layout: nil } # hack
      
    end
    
    def render(payload)
      do_layout(payload, { no_layout: nil })
    end
  end

  # Monkey patch for the Jekyll Convertible module.
  module Convertible

    def is_post?
      self.is_a? Jekyll::Post
    end

    def is_page?
      self.is_a? Jekyll::Page ||
      self.class.to_s == 'Octopress::Ink::Page'
    end

    def is_convertible_partial?
      self.is_a? Jekyll::ConvertiblePartial
    end

    def is_filterable?
      is_post? or is_page? or is_convertible_partial?
    end

    # Call the #pre_render methods on all of the loaded
    # page_hook plugins.
    #
    # Returns nothing
    def pre_render
      if self.site.page_hooks and is_filterable?
        self.site.page_hooks.each do |filter|
          filter.pre_render(self)
        end
      end
    end

    # Call the #post_render methods on all of the loaded
    # page_hook plugins.
    #
    # Returns nothing
    def post_render
      if self.site.page_hooks and is_filterable?
        self.site.page_hooks.each do |filter|
          filter.post_render(self)
        end
      end
    end

    # Call the #post_write methods on all of the loaded
    # page_hook plugins.
    #
    # Returns nothing
    def post_write
      if self.site.page_hooks and is_filterable?
        self.site.page_hooks.each do |filter|
          filter.post_write(self)
        end
      end
    end

    alias_method :old_transform, :transform
    alias_method :old_do_layout, :do_layout
    alias_method :old_write, :write

    # Transform the contents based on the content type. Then calls the
    # #post_render method if it exists
    #
    # Returns nothing.
    def transform
      old_transform
      post_render if respond_to?(:post_render)
    end

    # Calls the pre_render method if it exists and then adds any necessary
    # layouts to this convertible document.
    #
    # payload - The site payload Hash.
    # layouts - A Hash of {"name" => "layout"}.
    #
    # Returns nothing.
    def do_layout(payload, layouts)
      pre_render if respond_to?(:pre_render)
      old_do_layout(payload, layouts)
    end

    # Write the generated post file to the destination directory. It
    # then calls any post_write methods that may exist.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      old_write(dest)
      post_write if respond_to?(:post_write)
    end

    # Returns the full url of the post, including the configured url
    #
    def full_url
      File.join(self.site.config['url'], self.url)
    end
  end
end

