$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'merb-core'
require 'merb_global'
require 'spec'

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

require 'merb_global'

Spec::Runner.configure do |config|
  config.include(Merb::Test::ControllerHelper)
end
