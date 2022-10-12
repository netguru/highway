#
# Gemfile
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require_relative "lib/highway/version"

Gem::Specification.new do |spec|

  # Metadata

  spec.name = "highway"
  spec.version = Highway::VERSION
  spec.summary = "Build system on top of Fastlane."
  spec.homepage = "https://github.com/netguru/highway"
  spec.metadata    = { "source_code_uri" => "https://github.com/netguru/highway" }

  spec.author = "Netguru"
  spec.license = "MIT"

  # Sources

  spec.files = Dir['lib/**/*.rb']

  # Dependencies

  spec.add_dependency "fastlane", ">= 2.201.0", "<= 3.0.0"
  spec.add_dependency "slack-notifier", ">= 2.0.0", "<= 3.0.0"
  spec.add_dependency "uri-ssh_git", ">= 2.0.0", "<= 3.0.0"
  spec.add_dependency "xcpretty-json-formatter", ">= 0.1.1", "<= 1.0.0"
  spec.add_dependency "gpgme", ">= 2.0.0", "<= 3.0.0"
  spec.add_dependency "rubyzip", ">= 2.0.0", "<= 3.0.0"

  # Development Dependencies

  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.5.0"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
  
end
