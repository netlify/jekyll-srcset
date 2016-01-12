# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/srcset/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-srcset"
  spec.version       = Jekyll::Srcset::VERSION
  spec.authors       = ["Mathias Biilmann Christensen"]
  spec.email         = ["info@mathias-biilmann.net"]
  spec.summary       = %q{This Jekyll plugin ads an image_tag that will generate responsive img tags}
  spec.description   = %q{
  This Jekyll plugin makes it very easy to send larger images to devices with high pixel densities.

  The plugin adds an `image_tag` Liquid tag that can be used like this:

  \{% image_tag src="/image.png" width="100" %\}
}
  spec.homepage      = "https://github.com/netlify/jekyll-srcset"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rmagick"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency 'jekyll', '> 2'
end
