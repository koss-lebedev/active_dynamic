module ActiveDynamic
  module ActiveRecord

    def has_dynamic_attributes
      include ActiveDynamic::HasDynamicAttributes
    end

  end
end

ActiveRecord::Base.extend ActiveDynamic::ActiveRecord
