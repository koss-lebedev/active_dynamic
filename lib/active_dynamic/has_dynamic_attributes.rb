module ActiveDynamic
  module HasDynamicAttributes
    extend ActiveSupport::Concern

    included do
      has_many :active_dynamic_attributes, class_name: ActiveDynamic::Attribute, autosave: true, as: :customizable
      before_save :save_dynamic_attributes
    end

    def dynamic_attributes
      if persisted?
        active_dynamic_attributes.order(:created_at)
      else
        ActiveDynamic.configuration.provider_class.new(self.class).call
      end
    end

    def dynamic_attributes_loaded?
      @dynamic_attributes_loaded ||= false
    end

    def respond_to?(method_name, include_private = false)
      unless dynamic_attributes_loaded?
        load_dynamic_attributes
      end
      dynamic_attributes.find { |attr| attr.name == method_name.to_s.gsub(/=/, '') }.present? || super
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
      self.singleton_class.instance_eval do
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
        attr = self.active_dynamic_attributes.find_or_initialize_by(props)
        if _custom_fields[field.name]
          if self.persisted?
            attr.update(value: _custom_fields[field.name])
          else
            attr.assign_attributes(value: _custom_fields[field.name])
          end
        end
      end
    end

  end
end