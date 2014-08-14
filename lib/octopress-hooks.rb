require 'octopress-hooks/version'
require 'jekyll'

module Octopress  
  module Hooks

    class Site < Jekyll::Plugin

      # Called before after Jekyll reads in items
      # Returns nothing
      #
      def pre_read(site)
      end

      # Called right after Jekyll reads in all items, but before generators
      # Returns nothing
      #
      def post_read(site)
      end

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
    
    class Page < Jekyll::Plugin

      # Called after Page is initialized
      # allows you to modify a # page object before it is 
      # added to the Jekyll pages array
      #
      def post_init(post)
      end

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

    class Post < Jekyll::Plugin
      def post_init(post); end
      def pre_render(post); end
      def post_render(post); end
      def post_write(post); end
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
    attr_accessor :page_hooks, :post_hooks, :site_hooks

    # Instantiates all of the hook plugins. This is basically
    # a duplication of the other loaders in Site#setup.
    def load_hooks
      self.site_hooks = instantiate_subclasses(Octopress::Hooks::Site)
      self.page_hooks = instantiate_subclasses(Octopress::Hooks::Page)
      self.post_hooks = instantiate_subclasses(Octopress::Hooks::Post)
    end


    alias_method :old_site_payload, :site_payload
    alias_method :old_render, :render
    alias_method :old_write, :write
    alias_method :old_read, :read

    # Load hooks before read to ensure that Post and Page hooks 
    # can be triggered during initialization
    #
    def read
      self.load_hooks
      self.site_hooks.each do |hook|
        hook.pre_read(self)
      end

      old_read

      self.site_hooks.each do |hook|
        hook.post_read(self)
      end
    end

    # Allows site hooks to get access to the site before
    # the render method is called
    #
    # Returns nothing
    def render
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


  # Monkey patch Jekyll's Page class
  #
  class Page
    alias_method :old_initialize, :initialize

    def initialize(*args)
      old_initialize(*args)
      post_init if respond_to?(:post_init) && self.hooks
    end

    def hooks
      self.site.page_hooks
    end
  end

  # Monkey patch Jekyll's Post class
  #
  class Post
    alias_method :old_initialize, :initialize

    def initialize(*args)
      old_initialize(*args)
      post_init if respond_to?(:post_init) && self.hooks
    end

    def hooks
      self.site.post_hooks
    end
  end

  # Monkey patch for the Jekyll Convertible module.
  module Convertible
    alias_method :old_transform, :transform
    alias_method :old_do_layout, :do_layout
    alias_method :old_write, :write

    # Calls the pre_render method if it exists and then adds any necessary
    # layouts to this convertible document.
    #
    # payload - The site payload Hash.
    # layouts - A Hash of {"name" => "layout"}.
    #
    # Returns nothing.
    def do_layout(payload, layouts)
      pre_render if respond_to?(:pre_render) && self.hooks
      old_do_layout(payload, layouts)
      post_render if respond_to?(:post_render) && self.hooks
    end

    # Write the generated post file to the destination directory. It
    # then calls any post_write methods that may exist.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      old_write(dest)
      post_write if respond_to?(:post_write) && self.hooks
    end

    def hooks
      []
    end

    def post_init
      self.hooks.each do |hook|
        hook.post_init(self)
      end
    end
    
    def pre_render
      self.hooks.each do |hook|
        hook.pre_render(self)
      end
    end

    def post_render
      self.hooks.each do |hook|
        hook.post_render(self)
      end
    end

    def post_write
      self.hooks.each do |hook|
        hook.post_write(self)
      end
    end

    # Returns the full url of the post, including the configured url
    #
    def full_url
      File.join(self.site.config['url'], self.url)
    end
  end
end

