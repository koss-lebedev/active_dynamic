require 'test_helper'
require 'active_record'

class DynamicAttributesTest < Minitest::Test

  def setup
    DynamicAttributes.configure do |config|
      config.provider_class = ProfileAttributeProvider
    end

    @profile = Profile.new
  end

  def test_presence_of_version_number
    refute_nil ::DynamicAttributes::VERSION
  end

  def test_injects_custom_attributes
    assert_kind_of Array, @profile.dynamic_attributes
  end

  def test_sets_attribute_provider
    assert_respond_to @profile, :biography
  end

  def test_doesnt_reset_field_on_failed_save
    @profile.biography = 'My life'
    @profile.save

    assert_equal 'My life', @profile.biography
  end

end
