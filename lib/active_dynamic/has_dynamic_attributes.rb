module ActiveDynamic
  module HasDynamicAttributes
    extend ActiveSupport::Concern

    included do
      has_many :active_dynamic_attributes,
               class_name: ActiveDynamic::Attribute,
               autosave: true,
               as: :customizable
      before_save :save_dynamic_attributes
    end

    def dynamic_attributes
      if persisted?
        ActiveDynamic.configuration.resolve_persisted_proc.call(self) ? resolve_combined : resolve_from_db
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
        dynamic_attributes.find { |attr| attr.name == method_name.to_s.gsub(/=/, '') }.present?
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

    def resolve_combined
      attributes = resolve_from_db
      resolve_from_provider.each do |attribute|
        attributes << attribute unless attributes.find { |attr| attr.name == attribute.name }
      end
      attributes
    end

    def resolve_from_db
      active_dynamic_attributes.order(:created_at)
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
          _custom_fields[field.name] = value.strip if value
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
        props = { name: field.name, display_name: field.display_name,
                  datatype: field.datatype, value: field.value }
        attr = active_dynamic_attributes.find_or_initialize_by(props)
        if _custom_fields[field.name]
          if persisted?
            attr.update(value: _custom_fields[field.name])
          else
            attr.assign_attributes(value: _custom_fields[field.name])
          end
        end
      end
    end

  end
end
