# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mml2wav/version'

Gem::Specification.new do |spec|
  spec.name          = "mml2wav"
  spec.version       = Mml2wav::VERSION
  spec.authors       = ["Masafumi Yokoyama"]
  spec.email         = ["myokoym@gmail.com"]
  spec.description   = %q{MML (Music Macro Language) to WAV audio converter by Ruby.}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/myokoym/mml2wav"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("wavefile")
  spec.add_runtime_dependency("thor")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
