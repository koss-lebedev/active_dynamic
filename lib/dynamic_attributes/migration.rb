module DynamicAttributes
  class Migration < ActiveRecord::Migration

    def change
      create_table :dynamic_attributes do |t|
        t.references :customizable, polymorphic: true
        t.string :name, null: false
        t.text :value
        t.integer :datatype, null: false

        t.timestamps
      end
    end

  end
end
