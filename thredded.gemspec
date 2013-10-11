$:.push File.expand_path('../lib', __FILE__)

require 'thredded/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'thredded'
  s.version     = Thredded::VERSION
  s.authors     = ['Joel Oliveira']
  s.email       = ['joel@thredded.com']
  s.homepage    = 'https://www.thredded.com'
  s.summary     = 'A forum engine'
  s.license     = 'MIT'
  s.description = 'Extracted from the full rails app at thredded.com'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.mkdn']

  s.add_dependency 'RedCloth'
  s.add_dependency 'bb-ruby'
  s.add_dependency 'cancan'
  s.add_dependency 'carrierwave'
  s.add_dependency 'escape_utils'
  s.add_dependency 'fog'
  s.add_dependency 'friendly_id'
  s.add_dependency 'gravtastic'
  s.add_dependency 'htmlentities'
  s.add_dependency 'kaminari'
  s.add_dependency 'mini_magick'
  s.add_dependency 'multi_json'
  s.add_dependency 'nested_form'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rails', '>= 4.0'
  s.add_dependency 'rails_emoji'
  s.add_dependency 'redcarpet'
  s.add_dependency 'rspec-rails'
  s.add_dependency 'selenium-webdriver'
  s.add_dependency 'chromedriver-helper'
  s.add_dependency 'sass'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'chronic'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'chromedriver-helper'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sass'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'timecop'
end
