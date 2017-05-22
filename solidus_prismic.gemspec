# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_prismic/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_prismic'
  s.version     = SolidusPrismic::VERSION
  s.summary     = 'Solidus Prismic Client'
  s.description = 'Solidus Client for communicating with Prismic.io'
  s.license     = 'BSD-3-Clause'

  s.author    = 'Eric Saupe'
  s.email     = 'eric@sau.pe'
  s.homepage  = 'http://eric.sau.pe'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core'
  s.add_dependency 'prismic.io'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
