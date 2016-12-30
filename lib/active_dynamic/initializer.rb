ActiveDynamic.configure do |config|

  # Specify class inyour application responsible for resolving dynamic properties for your model.
  # this class should accept `model` as the only constructor parameter, and have a `call` method
  # that returns an array of AttributeDefinition
  config.provider_class = ActiveDynamic::NullProvider

end