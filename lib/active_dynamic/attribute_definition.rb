module ActiveDynamic
  class AttributeDefinition
    
    # These attributes are mandatory.
    attr_reader :display_name, :datatype, :value, :required, :name

    def initialize(display_name, datatype, default_value, required, options = {})
      @name = display_name.parameterize.underscore
      @display_name = display_name
      @datatype = datatype
      @value = default_value
      @required = required
      
      # Optional attributes from Provider
      options.each do |key, value|
        self.instance_variable_set("@#{key}", value)
        self.class.send(:attr_reader, key)
      end 
    end

    def required?
      !!@required
    end

  end
end