ActiveDynamic.configure do |config|

  # Specify class in your application responsible for resolving dynamic
  # properties for your model. This class should accept `model` as the
  # only constructor parameter, and have a `call` method that returns
  # an array of AttributeDefinition
  config.provider_class = ActiveDynamic::NullProvider
  
  # When new dynamic attributes are defined after object was saved, 
  # should object get this attributes automatically when editing? 
  # New attribute definitions are created automatically. 
  # Set true or false (default)
  # config.resolve_persisted = true

end
