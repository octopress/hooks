# Changelog

### 2.2.1 - 2014-08-13
- Fix: Now compatible with Jekyll 2.3.0

### 2.2.0 - 2014-07-28
- New: Site hook - pre_read, runs before site reads items
- New: Site hook - post_read, runs after site reads items

### 2.1.0 - 2014-07-28
- New: Added Post hooks.
- Change: Page hooks now only target pages.
- New: Added post_init hooks for pages and posts which is triggered after initialization.
- Gone: Removed the ConvertiblePartial thing. It was unnecessary. Extending hooks is easy.

### 2.0.0
- Added support for Site hooks: pre_render, post_write and a way to patch the site payload.
- Changed name to octopress-hooks and moved repository to octopress/hooks.

### 1.3.1
- No longer requires Octopress Ink.
- Renamed to octopress-hooks
- moved to https://github.com/octopress/hooks

### 1.3.0
- Added support for processing partials as a ConvertiblePartial.

### 1.2.0
- Added support Jekyll 2.0

### 1.1.1
- Added support for Octopress Ink.

### 1.1.0
- Added Jekyll::ConvertiblePage type to hookable classes.

### 1.0.2
- Now requires Jekyll (oops).
- Added tests.

### 1.0.1
- Naming refactor.

### 1.0.0
- Initial release.
