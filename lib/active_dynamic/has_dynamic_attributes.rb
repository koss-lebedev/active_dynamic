module ActiveDynamic
  module HasDynamicAttributes
    extend ActiveSupport::Concern

    included do
      has_many :active_dynamic_attributes,
               class_name: 'ActiveDynamic::Attribute',
               autosave: true,
               dependent: :destroy,
               as: :customizable
      before_save :save_dynamic_attributes
    end

    def dynamic_attributes
      if persisted? && any_dynamic_attributes?
        should_resolve_persisted? ? resolve_combined : resolve_from_db
      else
        resolve_from_provider
      end
    end

    def dynamic_attributes_loaded?
      @dynamic_attributes_loaded ||= false
    end

    def respond_to?(method_name, include_private = false)
      if super
        true
      else
        load_dynamic_attributes unless dynamic_attributes_loaded?
        dynamic_attributes.find { |attr| attr.name == method_name.to_s.delete('=') }.present?
      end
    end

    def method_missing(method_name, *arguments, &block)
      if dynamic_attributes_loaded?
        super
      else
        load_dynamic_attributes
        send(method_name, *arguments, &block)
      end
    end

    private

    def should_resolve_persisted?
      value = ActiveDynamic.configuration.resolve_persisted
      case value
      when TrueClass, FalseClass
        value
      when Proc
        value.call(self)
      else
        raise "Invalid configuration for resolve_persisted. Value should be Bool or Proc, got #{value.class}"
      end
    end

    def any_dynamic_attributes?
      active_dynamic_attributes.any?
    end

    def resolve_combined
      attributes = resolve_from_db
      resolve_from_provider.each do |attribute|
        attributes << ActiveDynamic::Attribute.new(attribute.as_json) unless attributes.find { |attr| attr.name == attribute.name }
      end
      attributes
    end

    def resolve_from_db
      active_dynamic_attributes.reload
    end

    def resolve_from_provider
      ActiveDynamic.configuration.provider_class.new(self).call
    end

    def generate_accessors(fields)
      fields.each do |field|

        add_presence_validator(field.name) if field.required?

        define_singleton_method(field.name) do
          _custom_fields[field.name]
        end

        define_singleton_method("#{field.name}=") do |value|
          _custom_fields[field.name] = value && value.to_s.strip
        end

      end
    end

    def add_presence_validator(attribute)
      singleton_class.instance_eval do
        validates_presence_of(attribute)
      end
    end

    def _custom_fields
      @_custom_fields ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def load_dynamic_attributes
      dynamic_attributes.each do |ticket_field|
        _custom_fields[ticket_field.name] = ticket_field.value
      end

      generate_accessors dynamic_attributes
      @dynamic_attributes_loaded = true
    end

    def save_dynamic_attributes
      dynamic_attributes.each do |field|
        next unless _custom_fields[field.name]
        attr = active_dynamic_attributes.find_or_initialize_by(field.as_json)
        if persisted?
          attr.update(value: _custom_fields[field.name])
        else
          attr.assign_attributes(value: _custom_fields[field.name])
        end
      end
    end

  end
end
