require "RMagick"
require "digest/sha1"

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

    def config(site)
      site.config['srcset'] || {}
    end

    def optimize?(site)
      config(site)['optipng']
    end

    def cache_dir(site)
      config(site)['cache']
    end

    def generate_image(site, src, attrs)
      cache = cache_dir(site)
      sha = cache && Digest::SHA1.hexdigest(attrs.sort.inspect + File.read(File.join(site.source, src)) + (optimize?(site) ? "optimize" : ""))
      if sha
        if File.exists?(File.join(cache, sha))
          img_attrs = JSON.parse(File.read(File.join(cache,sha,"json")))
          filename = img_attrs["src"].sub(/^\//, '')
          dest = File.join(site.dest, filename)
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(File.join(cache,sha,"img"), dest)

          site.config['keep_files'] << filename unless site.config['keep_files'].include?(filename)

          return img_attrs
        end
      end

      img = Image.read(File.join(site.source, src)).first
      img_attrs = {}

      if attrs["height"]
        scale = attrs["height"].to_f * (attrs["factor"] || 1) / img.rows.to_f
      elsif attrs["width"]
        scale = attrs["width"].to_f * (attrs["factor"] || 1) / img.columns.to_f
      else
        scale = attrs["factor"] || 1
      end

      img_attrs["height"] = attrs["height"] if attrs["height"]
      img_attrs["width"]  = attrs["width"]  if attrs["width"]
		img_width = img.columns * scale
		img_height = img.rows * scale
		img_attrs["src"] = src.sub(/(\.\w+)$/, "-" + (img_width.to_int.to_s) + "x" + (img_height.to_int.to_s) + '\1')

      filename = img_attrs["src"].sub(/^\//, '')
      dest = File.join(site.dest, filename)
      FileUtils.mkdir_p(File.dirname(dest))

      unless File.exist?(dest)
        img.scale!(scale) if scale <= 1
        img.strip!
        img.write(dest)
        if dest.match(/\.png$/) && optimize?(site) && self.class.optipng?
          `optipng #{dest}`
        end
      end
      site.config['keep_files'] << filename unless site.config['keep_files'].include?(filename)
      # Keep files around for incremental builds in Jekyll 3
      site.regenerator.add(filename) if site.respond_to?(:regenerator)

      if sha
        FileUtils.mkdir_p(File.join(cache, sha))
        FileUtils.cp(dest, File.join(cache, sha, "img"))
        File.open(File.join(cache, sha, "json"), "w") do |f|
          f.write(JSON.generate(img_attrs))
        end
      end

      img_attrs
    end
  end
end
