module ActiveDynamic
  class AttributeDefinition

    attr_reader :display_name, :datatype, :value, :name, :required

    def initialize(display_name, params = {})
      options = params.dup
      @name = (options.delete(:system_name) || display_name).parameterize.underscore
      @display_name = display_name
      @datatype = options.delete(:datatype)
      @value = options.delete(:default_value)
      @required = options.delete(:required) || false

      # custom attributes from Provider
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