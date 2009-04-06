# -*- encoding: utf-8 -*-


Gem::Specification.new do |s|
  s.name = "merb_global"
  s.version = "0.0.7"
  s.platform = Gem::Platform::RUBY
  s.summary = "Localization (L10n) and Internationalization (i18n) support for the Merb MVC Framework"
  s.description = s.summary
  s.authors = ["Alex Coles", "Maciej Piechotka", "Michael Johnston"]
  s.email = "merb_global@googlegroups.com"
  s.homepage = "http://trac.ikonoklastik.com/merb_global/"
  s.rubyforge_project = 'merb-global'
  s.add_dependency('merb-core', '>= 0.9.1')
  s.add_dependency('treetop', '>= 1.2.3') # Tested on 1.2.3
  s.require_path = 'lib'
  s.autorequire = "merb_global"
  s.files = %w(LICENSE README Rakefile TODO HISTORY) +
            Dir.glob("{lib,specs,*_generators,examples}/**/*")
  
  # rdoc
  s.has_rdoc = true
  s.extra_rdoc_files = %w(README LICENSE TODO HISTORY)
end
