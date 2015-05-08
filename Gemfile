require File.expand_path("../culture/sync", __FILE__)
Celluloid::Sync::Gemfile[self]

gem 'http'
gem 'multipart-parser',	github: 'penultimatix/multipart-parser'

gem 'jruby-openssl' if defined? JRUBY_VERSION
gem 'coveralls', require: false

gem 'certificate_authority'
gem 'jruby-openssl' if RUBY_PLATFORM == 'java'
gem 'celluloid-io', github: 'celluloid/celluloid-io', branch: '0.17.0-dependent', submodules: true

platforms :rbx do
  gem 'racc'
  gem 'rubinius-coverage'
  gem 'rubysl', '~> 2.0'
end