require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

PLUGIN = "merb_global"
NAME = "merb_global"
GEM_VERSION = "0.0.6"
AUTHORS = ["Alex Coles", "Maciej Piechotka"]
EMAIL = "merb_global@googlegroups.com"
HOMEPAGE = "http://trac.ikonoklastik.com/merb_global/"
SUMMARY = "Localization (L10n) and Internationalization (i18n) support for the Merb MVC Framework"

def spec
  require 'spec/rake/spectask'
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = GEM_VERSION
    s.platform = Gem::Platform::RUBY
    s.summary = SUMMARY
    s.description = s.summary
    s.authors = AUTHORS
    s.email = EMAIL
    s.homepage = HOMEPAGE
    s.rubyforge_project = 'merb-global'
    s.add_dependency('merb-core', '>= 0.9.1')
    s.add_dependency('treetop', '>= 1.2.3') # Tested on 1.2.3
    s.require_path = 'lib'
    s.autorequire = PLUGIN
    s.files = %w(LICENSE README Rakefile TODO HISTORY) +
              Dir.glob("{lib,specs,*_generators,examples}/**/*")
    
    # rdoc
    s.has_rdoc = true
    s.extra_rdoc_files = %w(README LICENSE TODO HISTORY)
  end
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install merb_global"
task :install => [:package] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION}}
end

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include "lib/**/*.rb"
end

desc "Creates database for examples"
task :populate_db do
  require 'fileutils'
  pwd = File.dirname __FILE__
  db = "#{pwd}/examples/database.db"
  sh %{sqlite3 #{db} < #{pwd}/examples/database.sql}
  FileUtils.cp db, "#{pwd}/examples/active_record_example/database.db"
  FileUtils.cp db, "#{pwd}/examples/data_mapper_example/database.db"
  FileUtils.cp db, "#{pwd}/examples/sequel_example/database.db"
end
task "pkg/#{NAME}-#{GEM_VERSION}" => [:populate_db]

namespace :cldr do
  desc "Force download and unzip of CLDR files"
  task :force_download do
    require 'net/http'
    require 'fileutils'
    
    FileUtils.mkdir_p [pwd, 'tmp', 'cldr-core']
    Net::HTTP.start('unicode.org') do |http|
      resp = http.get('/Public/cldr/1.6.1/core.zip')
      open("#{pwd}/tmp/cldr-core-1.6.1.zip", 'wb') do |file|
        file.write(resp.body)
      end
    end

    sh %{unzip -qo #{pwd}/tmp/cldr-core-1.6.1.zip -d #{pwd}/tmp/cldr-core}
  end

  desc "Download and unzip CLDR files"
  task :download

  
  if File.file?("#{pwd}/tmp/cldr-core-1.6.1.zip")
    task :download => [:force_download]
  end

  desc "Process CLDR"
  task :process do
    # TODO: Implement
  end
end

desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |st|
  st.libs = ['lib', 'spec']
  st.spec_files = FileList['spec/**/*_spec.rb']
  st.spec_opts = ['--format specdoc', '--color']
end

desc "Run rcov"
Spec::Rake::SpecTask.new('rcov') do |rct|
  rct.libs = ['lib', 'spec']
  rct.rcov = true
  rct.rcov_opts = ['-x gems', '-x usr', '-x spec']
  rct.spec_files = FileList['spec/**/*.rb']
  rct.spec_opts = ['--format specdoc', '--color']
end
