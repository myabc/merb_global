require 'spec_helper'

describe Merb::Global::Plural do
  describe ".which_form" do
    it "should call eval" do
      plural = "n"
      Merb::Global::Plural.expects(:eval).with(plural)
      Merb::Global::Plural.which_form mock, plural
    end
  end
end
