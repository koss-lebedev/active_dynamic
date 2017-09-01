require 'test_helper'
require 'active_record'

class ActiveDynamicTest < Minitest::Test

  def setup
    ActiveDynamic.configure do |config|
      config.provider_class = ProfileAttributeProvider
      config.resolve_persisted = false
    end

    @profile = Profile.new
  end

  def test_initializes_with_dynamic_attribute
    profile = Profile.new(first_name: 'Dwight', life_story: 'Beet farmer / Paper Salesman')
    profile.save!

    assert profile.persisted?
  end

  def test_presence_of_version_number
    refute_nil ::ActiveDynamic::VERSION
  end

  def test_injects_dynamic_attributes
    assert_kind_of Array, @profile.dynamic_attributes
  end

  def test_has_dynamic_attributes_loaded_method
    assert_respond_to @profile, :dynamic_attributes_loaded?
  end

  def test_sets_attribute_provider
    puts @profile.life_story
    assert_respond_to @profile, :life_story
  end

  def test_sets_name
    assert_equal @profile.dynamic_attributes.map(&:name).first, 'life_story'.freeze
    assert_equal @profile.dynamic_attributes.map(&:name).last, 'home_town'.freeze
  end

  def test_sets_display_name
    assert_equal @profile.dynamic_attributes.map(&:display_name).first, 'Life Story'.freeze
  end

  def test_doesnt_reset_field_on_failed_save
    @profile.life_story = 'Beet farmer / Paper Salesman'
    @profile.save

    refute @profile.persisted?
    assert_equal 'Beet farmer / Paper Salesman', @profile.life_story
  end

  def test_persists_dynamic_attribute
    @profile.first_name = 'Dwight'
    @profile.life_story = 'Beet farmer / Paper Salesman'
    @profile.save

    assert @profile.persisted?
    refute_empty @profile.life_story
  end

  def test_persists_if_initialized_with_attrs
    profile = Profile.new(first_name: 'Michael', life_story: 'Basketball machine')
    profile.save

    assert profile.persisted?
    refute_empty profile.life_story
  end

  def test_loads_dynamic_attributes_on_find
    @profile.first_name = 'Dwight'
    @profile.life_story = 'Beet farmer / Paper Salesman'
    @profile.save

    loaded_profile = Profile.find(@profile.id)
    assert_equal 'Beet farmer / Paper Salesman', loaded_profile.life_story
  end

  def test_validates_required_attribute
    @profile.life_story = nil
    @profile.save

    assert !@profile.persisted?
  end

  def test_handles_resolve_persisted_with_bool_value
    ActiveDynamic.configure do |config|
      config.provider_class = ProfileAttributeProvider
      config.resolve_persisted = true
    end

    profile = Profile.new

    assert profile.send(:should_resolve_persisted?)
  end

  def test_handles_resolve_persisted_with_proc_value
    ActiveDynamic.configure do |config|
      config.provider_class = ProfileAttributeProvider
      config.resolve_persisted = Proc.new { |model| true }
    end

    profile = Profile.new

    assert profile.send(:should_resolve_persisted?)
  end

  def test_supports_integer_values
    profile = Profile.new
    profile.age = 21

    assert true
  end

end
