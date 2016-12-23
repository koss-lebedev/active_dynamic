require 'test_helper'
require 'active_record'

class DynamicAttributesTest < Minitest::Test

  def test_presence_of_version_number
    refute_nil ::DynamicAttributes::VERSION
  end

  def test_injection_of_custom_attributes
    Profile.new.custom_attributes
  end

end
