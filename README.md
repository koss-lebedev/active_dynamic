# ActiveDynamic

[![Gem Version](https://badge.fury.io/rb/active_dynamic.svg)](https://badge.fury.io/rb/active_dynamic)
[![Code Climate](https://codeclimate.com/github/koss-lebedev/active_dynamic/badges/gpa.svg)](https://codeclimate.com/github/koss-lebedev/active_dynamic)
[![Build Status](https://travis-ci.org/koss-lebedev/active_dynamic.svg?branch=master)](https://travis-ci.org/koss-lebedev/active_dynamic)

ActiveDynamic allows to dynamically add properties to your ActiveRecord models and 
work with them as regular properties.
To see this in practice, check out the demo application available at [https://github.com/koss-lebedev/active_dynamic_demo](https://github.com/koss-lebedev/active_dynamic_demo).
I also wrote [an article](https://medium.com/@koss_lebedev/how-to-dynamically-add-attributes-to-your-activerecord-models-e233b17ad695#.k66n002of) explaining how to use active_dynamic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_dynamic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_dynamic

## Usage

To make this gem work, first you need to add `has_dynamic_attributes` to the model that needs to have dynamic 
attributes. For example, if you have `Profile` model:
 
```ruby
class Profile < ActiveRecord::Base
  has_dynamic_attributes
  
  # ...
end  
```

After that you need to set a class that will resolve definitions of the dynamic attributes to be created on `Profile` model:

```ruby
# lib/initializers/dynamic_attribute.rb

ActiveDynamic.configure do |config|
  config.provider_class = ProfileAttributeProvider
end

class ProfileAttributeProvider

  # Constructor will receive a class to which dynamic attributes are added
  def initialize(model_class)
    @model_class = model_class    
  end
  
  # This method has to return array of dynamic field definitions.
  # You can get it from the configuration file, DB, etc., depending on your app logic
  def call
    [
      # attribute definition has to specify attribute display name
      ActiveDynamic::AttributeDefinition.new('biography'),
      
      # Optionally you can provide datatype, system name, and default value.
      # If system name is not specified, it will be generated automatically from display name
      ActiveDynamic::AttributeDefinition.new('age', datatype: ActiveDynamic::DataType::Integer, default_value: 18)
    ]
  end
  
end

```

To resolve dynamic attribute definitions for more than one model:

```ruby
class Profile < ActiveRecord::Base
  has_dynamic_attributes
  
  # ...
end  
 
class Document < ActiveRecord::Base
  has_dynamic_attributes
  
  # ...
end  
 
class ProfileAttributeProvider
 
  def initialize(model_class)
    @model_class = model_class    
  end
  
  def call
    if @model_class == Profile
      [
        # attribute definitions for Profile model
      ] 
    elsif @model_class == Document
      [
        # attribute definitions for Document model
      ] 
    else
      []
    end
  end
  
end
```

## How ActiveDynamic resolves dynamic attributes

When you work with unsaved models, ActiveDynamic will use `provider_class` to resolve a list 
of dynamic attributes, and it will store them alongside the model when the model is saved. 
So next time when you load that model from DB, ActiveDynamic won't look into `provider_class` 
and it will load only the dynamic attributes that were created when the model was saved for 
the first time.

If you want dynamic attributes to be resolved from `provider_class` for persisted models as well,
you can use `resolve_persisted` configuration option:

```ruby
# lib/initializers/dynamic_attribute.rb

ActiveDynamic.configure do |config|
  # ... 
  
  # you can set it to Bool value to apply 
  # the behavior to all models
  config.resolve_persisted = true
  
  # or you can set it to a Proc to configure the behavior
  # on per-class basis
  config.resolve_persisted = Proc.new { |model| model.is_a?(Profile) ? true  : false }
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/koss-lebedev/active_dynamic. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

