require 'rubygems'

# Providers
def load_provider_lib(*libs)
  begin
    libs.each {|lib| require lib}
    true
  rescue Gem::LoadError => e
    warn "Could not load #{lib}: #{e}"
    false
  end
end

HAS_AR      = load_provider_lib 'activerecord'
HAS_DM      = load_provider_lib 'dm-core', 'dm-validations', 'dm-aggregates'
HAS_GETTEXT = load_provider_lib 'gettext'
HAS_SEQUEL  = load_provider_lib 'sequel'

require 'merb-core'

Merb::Plugins.config[:merb_global] = {
  :provider => 'mock',
  :localedir => File.join('spec', 'locale')
}

require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path.to_s + '/lib/merb_global'

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

require 'spec'

Spec::Runner.configure do |config|
  config.include(Merb::Test::ControllerHelper)
  config.mock_with :mocha
end
