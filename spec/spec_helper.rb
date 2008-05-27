require 'rubygems'
require 'pathname'
require 'merb-core'

Merb::Plugins.config[:merb_global] = {
  :provider => 'mock',
  :localedir => File.join('spec', 'locale')
}

require 'spec'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/merb_global'

# Providers
def load_provider_lib(name, options = {})
  lib       = "#{name}"
  version   = options[:version]
  gem_names = if !options[:gem_names].nil?
    options[:gem_names]
  else
    lib
  end

  begin
    if !version.nil?
      gem_names.each { |g| gem g, version }
    else
      gem_names.each { |g| gem g }
    end
    require lib
    true
  rescue Gem::LoadError => e
    warn "Could not load #{lib}: #{e}"
    false
  end
end

HAS_AR      = load_provider_lib(:activerecord)
HAS_DM03    = load_provider_lib(:data_mapper, :version => '=0.3')
HAS_DM09    = load_provider_lib(:data_mapper, :version => '=0.9.0', :gem_names => [ 'dm-core', 'dm-validations', 'dm-aggregates'])
HAS_GETTEXT = load_provider_lib(:gettext)
HAS_SEQUEL  = load_provider_lib(:sequel)

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ControllerHelper)
  config.mock_with :mocha
end
