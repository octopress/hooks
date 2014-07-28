# Octopress Hooks

Modify Jekyll's Site, Pages and Posts at different points during the site processing stream.

## Installation

Add this line to your application's Gemfile:

    gem 'octopress-hooks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install octopress-hooks

## Usage

First extend the appropriate Hook class.

- `Octopress::Hooks::Site` - access Jekyll's Site instance.
- `Octopress::Hooks::Page` - access to each of Jekyll's Page instances.
- `Octopress::Hooks::Post` - access to each of Jekyll's Post instances.

Then add a method based on when you want to trigger your hooks.

#### Site Hooks

The Site class has three methods. Here's an example.

```
class MySiteHook < Octopress::Hooks::Site
  
  def pre_render(site)
  end

  def merge_payload(payload, site)
  end

  def post_write(site)
  end
end
```

Use the `pre_render` hook to modify the site instance before posts and pages are rendered.

Use the `merge_paylod` hook to modify the site payload or merge custom data into it. This data will be available to all documents when they are rendered. This method must return a hash.

Use the `post_write` to trigger and action after all documents have been written to disk.

#### Post/Page hooks

The Page and Post hooks have four methods and are identical except that Post hooks only operate on posts, and Page hooks only operate on
pages. Here's an example of a Page hook.

```
class MySiteHook < Octopress::Hooks::Page

  def post_init(page)
  end
  
  def pre_render(page)
  end

  def post_render(page)
  end

  def post_write(page)
  end
end
```

The `post_init` method lets you access the post or page class instance immediately after it has been initialized. This allows you to
modify the instance before the Site compiles its payload, which includes arrays of each page and post.

With `pre_render` you can parse and modify page contents before it is processed by Liquid, Markdown, Textile and the like, and rendered to HTML.

With `post_render` you can access pages and posts after it has been converted into HTML. You might use this option if you want to modify generated HTML.

With `post_write` you can execute a code block after a page or post has been successfully written to disk.

To run an action on both posts and pages, you'd do something like this.

```ruby
module MyModule
  def self.do_awesome(document)
    # something awesome
  end

  MyPostHook < Octopress::Hooks::Post
    def pre_render(post)
      do_awesome(post)
    end
  end

  MyPostHook < Octopress::Hooks::Page
    def pre_render(post)
      MyModule.do_awesome(post)
    end
  end
end
```

### Hook timeline

Just to be clear, this is the order in which these hooks are triggered.

1. Post/Page `post_init`
2. Site `pre_render`
3. Site `merge_payload`
4. Post/Page `pre_render`
5. Post/Page `post_render`
6. Post/Page `post_write`
7. Site `post_write`

## Contributing

1. Fork it ( https://github.com/octopress/hooks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

