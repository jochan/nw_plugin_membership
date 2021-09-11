lib = File.expand_path("../lib", __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nw_plugin_membership/version"

Gem::Specification.new do |spec|
  spec.name          = "nw_plugin_membership"
  spec.version       = NwPluginMembership::VERSION
  spec.authors       = ["Joshua Chan"]
  spec.email         = ["jchan.is@gmail.com"]

  spec.summary       = "Niiwin Plugin to add a geolocation point attribute type."
  spec.homepage      = "https://github.com/jochan/nw_plugin_membership"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir["{app,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  spec.add_dependency "niiwin", "~> 0.6.0"
  spec.add_dependency "byebug", "~> 11.1.3"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
