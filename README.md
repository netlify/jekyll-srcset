# Jekyll Srcset

This Jekyll plugin makes it very easy to send larger images to devices with high pixel densities.

The plugin adds an `image_tag` Liquid tag that can be used like this:

```html
{% image_tag src="/image.png" width="100" %}
```

This will generate the right images and output something like:

```html
<img src="/image-100x50.png" srcset="/image-100x50.png 1x, /image-200x100.png 2x, /image-300x150.png 3x" width="100">
```

## Installation

Add this line to your Gemfile:

```ruby
gem 'jekyll-srcset'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-srcset

Then add the gem to your Jekyll `_config.yml`:

```yml
gems:
  - jekyll-srcset
```

## Usage

Use it like this in any Liquid template:

```html
{% image_tag src="/image.png" width="100" %}
```

You must specify either a `width` or a `height`, but never both. The width or height will be used to determine the smallest version of the image to use (for 1x pixel density devices). Based on this minimum size, the plugin will generate up to 3 versions of the image, one that matches the dimension specified, one that's twice the size and one that's 3 times the size. The plugin never upscales an image.

The plugin sets these as a srcset attribute on the final image tag, and modern browsers will then use this information to determine which version of the image to load based on the pixel density of the device (and in the future, potentially based on bandwidth or user settings).

This makes it a really straight forward way to serve the right size of image in all modern browsers and in works fine in older browsers without any polyfill (there's not a lot of high pixel density devices out there that runs old browsers, so simply serving the smallest version to the ones that don't understand srcset is fine).

To use variables for the image or the dimensions, simply leave out the quotes:

```html
{% image_tag src=page.cover_image height=page.cover_image_height %}
```

## Optipng

If you have `optipng` installed and in your PATH, you can tell the plugin to run it on all generated png images.

Just add:

```
srcset:
  optipng: true
```

To your \_config.yml

Currently the plugin doesn't optimize other image formats, except for stripping color palettes.

## Caching images

Optimizing and resizing can take a while for some images. You can specify a cache folder in your Jekyll config to let jekyll-srcset cache images between runs.

```
srcset:
  cache: "/tmp/images"
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/jekyll-srcset/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Host your Jekyll sites with netlify

This plugin is developed by netlify, [the premium hosting for static websites](https://www.netlify.com).

You can use netlify if you're using custom plugins with your Jekyll sites. When you push to git, netlify will build your Jekyll site and deploy the result to a global CDN, while handling asset fingerprinting, caching headers, bundling, minification and true instant cache invalidation. A 1-click operation with no other setup needed.
