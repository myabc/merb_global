require 'spec_helper'

module Merb::Global::Plural
  def self.parser
    @parser
  end
end

describe Merb::Global::Plural do
  describe '.which_form' do
    it 'should parse the plural' do
      plural = mock
      n = mock
      result = mock
      tree = mock
      _lambda = mock
      _lambda.expects(:call).with(n).returns(result)
      tree.expects(:to_lambda).returns(_lambda)
      Merb::Global::Plural.parser.expects(:parse).with(plural).returns(tree)
      Merb::Global::Plural.which_form(n, plural).should == result
    end
  end
end
