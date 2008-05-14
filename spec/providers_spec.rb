require 'spec_helper'

describe Merb::Global::Providers do
  describe '.localedir' do
    it 'should return app/locale by default' do
      Merb::Plugins.stubs(:config).returns({})
      expected = File.join Merb.root, 'app', 'locale'
      Merb::Global::Providers.localedir.should == expected
    end
    it 'should return locale when flat option setted' do
      Merb::Plugins.stubs(:config).returns({:merb_global => {:flat => true}})
      expected = File.join Merb.root, 'locale'
      Merb::Global::Providers.localedir.should == expected
    end
    it 'should return user setted path' do
      config = {:merb_global => {:localedir => 'test'}}
      Merb::Plugins.stubs(:config).returns(config)
      expected = File.join Merb.root, 'test'
      Merb::Global::Providers.localedir.should == expected
    end
  end
end
