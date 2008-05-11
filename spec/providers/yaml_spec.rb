require 'spec_helper'
require 'merb_global/providers/yaml'

describe Merb::Global::Providers::Yaml do
  describe '._supported?' do
    it 'should return true if file exists' do
      provider = Merb::Global::Providers::Yaml.new
      file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(file).returns(true)
      YAML.stubs(:load_file).returns(mock)
      provider.supported?('en').should == true
    end
    it 'should return false if file doesn\'t exist' do
      provider= Merb::Global::Providers::Yaml.new
      file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(file).returns(false)
      YAML.stubs(:load_file).returns(mock)
      provider.supported?('en').should == false
    end
  end
  describe '.translate_to' do
    it 'should load file if file exists' do
      provider = Merb::Global::Providers::Yaml.new
      yaml_file = File.join Merb.root, 'app', 'locale', 'en.yaml'
      File.expects(:exist?).with(yaml_file).returns(true)
      YAML.expects(:load_file).with(yaml_file).returns(nil)
      provider.translate_to "test", "tests", :lang => 'en', :n => 1
    end
    it 'should check appropiete form' do
      provider = Merb::Global::Providers::Yaml.new
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
      translated = provider.translate_to "test", "test", :lang => 'en', :n => 1
      translated.should == "tests"
    end
  end
end
