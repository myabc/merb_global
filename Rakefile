require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require "spec/rake/spectask"

PLUGIN = "merb_global"
NAME = "merb_global"
GEM_VERSION = "0.0.1"
AUTHOR = "Alex Coles"
EMAIL = "alex@alexcolesportfolio.com"
HOMEPAGE = "http://github.com/myabc/merb_global/wikis"
SUMMARY = "Localization (L10n) and Internationalization (i18n) support for the Merb MVC Framework"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb-core', '>= 0.9.1')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
  
  # rdoc
  s.has_rdoc = true
  s.extra_rdoc_files = %w( README LICENSE TODO )
end

windows = (PLATFORM =~ /win32|cygwin/) rescue nil

SUDO = windows ? "" : "sudo"

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install merb_global"
task :install => [:package] do
  sh %{#{SUDO} gem install pkg/#{NAME}-#{VERSION}}
end
