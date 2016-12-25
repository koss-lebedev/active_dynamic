module ActiveDynamic
  module HasDynamicAttributes
    extend ActiveSupport::Concern

    included do
      has_many :custom_attributes, class_name: ActiveDynamic::Attribute, autosave: true, as: :customizable

      after_initialize :load_dynamic_attributes
      before_save :save_dynamic_attributes
    end

    def dynamic_attributes
      persisted? ? custom_attributes.order(:created_at) : ActiveDynamic.configuration.provider_class.new(self).call
    end

    def dynamic_attr_names
      dynamic_attributes.map(&:name)
    end

  private

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
        attr = custom_attributes.find_or_initialize_by(name: field.name, datatype: field.datatype)
        attr.update(value: _custom_fields[field.name]) if _custom_fields[field.name]
      end
    end

  end
end

ActiveRecord::Base.send(:include, ActiveDynamic::HasDynamicAttributes)