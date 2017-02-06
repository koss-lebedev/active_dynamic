module ActiveDynamic
  module HasDynamicAttributes
    extend ActiveSupport::Concern

    included do
      has_many :active_dynamic_attributes, class_name: ActiveDynamic::Attribute, autosave: true, as: :customizable

      before_save :save_dynamic_attributes
      after_find :load_dynamic_attributes
    end

    def dynamic_attributes
      if persisted?
        active_dynamic_attributes.order(:created_at)
      else
        ActiveDynamic.configuration.provider_class.new(self).call
      end
    end

  private

    # use internal ActiveModel callback to generate accessors for dynamic attributes
    # before attributes get assigned
    def initialize_internals_callback
      load_dynamic_attributes
      super
    end

    def generate_accessors(fields)
      fields.map(&:name).each do |field|

        define_singleton_method(field) do
          _custom_fields[field]
        end

        define_singleton_method("#{field}=") do |value|
          _custom_fields[field] = value.strip
        end

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
    end

    def save_dynamic_attributes
      dynamic_attributes.each do |field|
        attr = self.active_dynamic_attributes.find_or_initialize_by(name: field.name, datatype: field.datatype)
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