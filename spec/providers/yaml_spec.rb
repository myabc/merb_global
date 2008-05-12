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
      file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(file).returns(true)
      YAML.stubs(:load_file).returns(mock)
      @provider.support?('en').should == true
    end
    it 'should return false if file doesn\'t exist' do
      file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(file).returns(false)
      YAML.stubs(:load_file).returns(mock)
      @provider.support?('en').should == false
    end
  end
  describe '.translate_to' do
    it 'should load file if file exists' do
      yaml_file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(yaml_file).returns(true)
      YAML.expects(:load_file).with(yaml_file).returns(nil)
      @provider.translate_to "test", "tests", :lang => 'en', :n => 1
    end
    it 'should mark nil if file do not exists' do
      yaml_file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(yaml_file).returns(false)
      @provider.translate_to "test", "tests", :lang => 'en', :n => 1
      @provider.lang.should include("en")
      @provider.lang["en"].should be_nil
    end
    it 'should check appropiete form' do
      yaml_file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      file_content = {
        :plural => "n==1?1:0",
        "test" => {
          0 => "test",
          1 => "tests"
        }
      }
      File.expects(:exist?).with(yaml_file).returns(true)
      YAML.expects(:load_file).with(yaml_file).returns(file_content)
      expected = [1, file_content[:plural]]
      Merb::Global::Plural.expects(:which_form).with(*expected).returns(1)
      translated = @provider.translate_to "test", "test", :lang => 'en', :n => 1
      translated.should == "tests"
    end
  end
  describe '.create!' do
    it "should create app/locale firectory" do
      file = File.join Merb.root, 'app', 'locale'
      File.expects(:mkdirs).with(file).returns([file])
      @provider.create!
    end
  end
end
