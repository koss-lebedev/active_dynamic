require 'test_helper'
require 'active_record'

class ActiveDynamicTest < Minitest::Test

  def setup
    ActiveDynamic.configure do |config|
      config.provider_class = ProfileAttributeProvider
    end

    @profile = Profile.new
  end

  def test_presence_of_version_number
    refute_nil ::ActiveDynamic::VERSION
  end

  def test_injects_dynamic_attributes
    assert_kind_of Array, @profile.dynamic_attributes
  end

  def test_sets_attribute_provider
    assert_respond_to @profile, :biography
  end

  def test_doesnt_reset_field_on_failed_save
    @profile.biography = 'Beet farmer / Paper Salesman'
    @profile.save

    refute @profile.persisted?
    assert_equal 'Beet farmer / Paper Salesman', @profile.biography
  end

  def test_persists_dynamic_attribute
    @profile.first_name = 'Dwight'
    @profile.biography = 'Beet farmer / Paper Salesman'
    @profile.save

    assert @profile.persisted?
    refute_empty @profile.biography
  end

end
