$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_dynamic'
require 'active_dynamic/migration'

require 'minitest/autorun'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :profiles, force: true do |t|
    t.string :first_name
    t.string :last_name
  end

  create_table :active_dynamic_attributes, force: true do |t|
    t.integer :customizable_id, null: false
    t.string :customizable_type, limit: 50

    t.string :name, null: false
    t.text :value
    t.integer :datatype, null: false

    t.timestamps
  end

  add_index :active_dynamic_attributes, :customizable_id
  add_index :active_dynamic_attributes, :customizable_type

end

class Profile < ActiveRecord::Base
  validates :first_name, presence: true
end

class ProfileAttributeProvider

  def initialize(model)

  end

  def call
    [
        Struct.new(:name, :datatype, :value).new('biography', ActiveDynamic::DataType::Text, nil)
    ]
  end

end