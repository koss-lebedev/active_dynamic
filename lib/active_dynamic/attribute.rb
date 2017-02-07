module ActiveDynamic
  class Attribute < ActiveRecord::Base
    belongs_to :customizable, polymorphic: true

    self.table_name = 'active_dynamic_attributes'
    validates :name, presence: true
    validates :datatype, presence: true
  end
end
