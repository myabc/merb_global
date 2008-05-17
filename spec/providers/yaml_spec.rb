require 'spec_helper'
require 'merb_global/providers/yaml'

class Merb::Global::Providers::Yaml
  attr_reader :lang
end

describe Merb::Global::Providers::Yaml do
  before do
    @provider = Merb::Global::Providers::Yaml.new
  end
  describe '._support?' do
    it 'should return true if file exists' do
      @provider.support?('pl').should == true
    end
    it 'should return false if file doesn\'t exist' do
      @provider.support?('fr').should == false
    end
  end
  describe '.translate_to' do
    it 'should mark nil if file do not exists' do
      @provider.translate_to "Test", "Tests", :lang => 'fr', :n => 1
      @provider.lang.should include("fr")
      @provider.lang["fr"].should be_nil
    end
    it 'should check appropiete form' do
      translated = @provider.translate_to "Test", "Tests",
                                          :lang => 'pl', :n => 2
      translated.should == "Testy"
    end
  end
  describe '.create!' do
    it "should create app/locale firectory" do
      file = Merb::Global::Providers.localedir
      File.expects(:mkdirs).with(file).returns([file])
      @provider.create!
    end
  end
end
