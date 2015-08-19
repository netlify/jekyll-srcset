require "RMagick"

module Jekyll
  class SrcsetTag < Liquid::Tag
    include Magick
    attr_accessor :markup

    def self.optipng?
      @optinpng ||= system("which optipng")
    end

    def initialize(tag_name, markup, _)
      @markup = markup
      super
    end

    def render(context)
      options = parse_options(markup, context)

      return "Bad options to image_tag, syntax is: {% image_tag src=\"image.png\" width=\"100\"}" unless options["src"]
      return "Error resizing - can't set both width and height" if options["width"] && options["height"]

      site = context.registers[:site]
      img_attrs = generate_image(site, options["src"], options)

      srcset = []
      (1..3).each do |factor|
        srcset << {:factor => factor, :img => generate_image(site, options["src"], options.merge("factor" => factor))}
      end
      img_attrs["srcset"] = srcset.map {|i| "#{i[:img]["src"]} #{i[:factor]}x"}.join(", ")

      "<img #{options.merge(img_attrs).map {|k,v| "#{k}=\"#{v}\""}.join(" ")}>"
    end

    def parse_options(markup, context)
      options = {}
      markup.scan(/(\w+)=((?:"[^"]+")|(?:'[^']+')|[\w\.\_-]+)/) do |key,value|
        if (value[0..0] == "'" && value[-1..-1]) == "'" || (value[0..0] == '"' && value[-1..-1] == '"')
          options[key] = value[1..-2]
        else
          options[key] = context[value]
        end
      end
      options
    end

    def generate_image(site, src, attrs)
      img = Image.read(File.join(site.source, src)).first
      img_attrs = {}

      if attrs["height"]
        scale = attrs["height"].to_f * (attrs["factor"] || 1) / img.rows.to_f
      elsif attrs["width"]
        scale = attrs["width"].to_f * (attrs["factor"] || 1) / img.columns.to_f
      else
        scale = attrs["factor"] || 1
      end

      img.scale!(scale) if scale <= 1
      img_attrs["height"] = attrs["height"] if attrs["height"]
      img_attrs["width"]  = attrs["width"]  if attrs["width"]

      img_attrs["src"] = src.sub(/(\.\w+)$/, "-#{img.columns}x#{img.rows}" + '\1')
      filename = img_attrs["src"].sub(/^\//, '')
      dest = File.join(site.dest, filename)
      FileUtils.mkdir_p(File.dirname(dest))
      unless File.exist?(dest)
        img.strip!
        img.write(dest)
        if dest.match(/\.png$/) && self.class.optipng?
          `optipng #{dest}`
        end
      end
      site.config['keep_files'] << filename unless site.config['keep_files'].include?(filename)
      img_attrs
    end
  end
end
