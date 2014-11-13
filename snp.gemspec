$:.push File.expand_path("../lib", __FILE__)
require 'snp/version'

Gem::Specification.new do |s|
  s.name        = 'snp'
  s.version     = Snp::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Quickly and easily create code snippets.'
  s.email       = 'mascarenhas.renato@gmail.com'
  s.homepage    = ''
  s.description = 'Quickly and easily create code snippets.'
  s.authors     = ['Renato Mascarenhas']
  s.license     = 'MIT'

  s.files         = Dir['MIT-LICENSE', 'README.md', 'lib/**/*']
  s.test_files    = Dir['test/**/*.rb']
  s.require_paths = ['lib']

  s.add_runtime_dependency 'slop'
  s.add_development_dependency 'mocha'
  s.rubyforge_project = 'snp'
end
