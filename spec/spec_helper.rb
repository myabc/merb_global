$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'merb-core'

Merb::Plugins.config[:merb_global] = {:provider=> 'mock'}

require 'merb_global'
require 'spec'

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ControllerHelper)
end
