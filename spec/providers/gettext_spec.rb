require 'spec_helper'
require 'merb_global/providers/gettext'

localedir =
  (Pathname(__FILE__).dirname.parent.parent.expand_path + 'spec/locale').to_s

describe Merb::Global::Providers::Gettext do
  before do
    @provider = Merb::Global::Providers::Gettext.new
  end
  describe '.create!' do
    it 'should create directory' do
      Merb::Global::Providers.expects(:localedir).returns(localedir)
      File.expects(:mkdirs).with(localedir)
      @provider.create!
    end
  end
  describe '.support?' do
    it 'should return true if directory exists' do
      Merb::Global::Providers.expects(:localedir).returns(localedir)
      @provider.support?('pl').should == true
    end
    it 'should return false otherwise' do
      Merb::Global::Providers.stubs(:localedir).returns(localedir)
      @provider.support?('fr').should == false
    end
  end
  describe '.translate_to' do
    it 'should translate the string' do
      Merb::Global::Providers.stubs(:localedir).returns(localedir)
      trans = @provider.translate_to 'Test', 'Tests', :n => 1, :lang => 'pl'
      trans.should == 'Test'
      trans = @provider.translate_to 'Test', 'Tests', :n => 2, :lang => 'pl'
      trans.should == 'Testy'
      trans = @provider.translate_to 'Test', 'Tests', :n => 5, :lang => 'pl'
      trans.should == 'Testów'
    end
    it 'should fallback if not present' do
      Merb::Global::Providers.stubs(:localedir).returns(localedir)
      trans = @provider.translate_to 'Car', 'Cars', :n => 1, :lang => 'pl'
      trans.should == 'Car'
      trans = @provider.translate_to 'Car', 'Cars', :n => 2, :lang => 'pl'
      trans.should == 'Cars'
    end
    it 'should fallback if language is not supported' do
      Merb::Global::Providers.stubs(:localedir).returns(localedir)
      trans = @provider.translate_to 'Test', 'Tests', :n => 1, :lang => 'fr'
      trans.should == 'Test'
      trans = @provider.translate_to 'Test', 'Tests', :n => 2, :lang => 'fr'
      trans.should == 'Tests'
    end
  end
end
