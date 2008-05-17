require 'rubygems'
require 'pathname'
require 'merb-core'

Merb::Plugins.config[:merb_global] = {
  :provider => 'mock',
  :localedir => File.join('spec', 'locale')
}

require 'spec'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/merb_global'

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ControllerHelper)
  config.mock_with :mocha
end
