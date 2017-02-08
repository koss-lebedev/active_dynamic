module ActiveDynamic
  class AttributeDefinition

    attr_reader :display_name, :name, :datatype, :value

    def initialize(display_name, options = {})
      @display_name = display_name
      @name = options[:system_name] || display_name.gsub(/[^a-zA-Z\s]/, ''.freeze).gsub(/\s+/, '_'.freeze)
      @datatype = options[:datatype]
      @value = options[:default_value]
    end

  end
end
