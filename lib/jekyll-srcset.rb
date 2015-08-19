require "jekyll/srcset"

Liquid::Template.register_tag('image_tag', Jekyll::SrcsetTag)
