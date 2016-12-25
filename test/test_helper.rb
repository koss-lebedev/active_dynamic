$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dynamic_attributes'

require 'minitest/autorun'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :profiles, force: true do |t|
    t.string :first_name
    t.string :last_name
  end

end

class Profile < ActiveRecord::Base
  validates :first_name, presence: true
end

class ProfileAttributeProvider

  def initialize(model)

  end

  def call
    [
        Struct.new(:name, :datatype, :value).new('biography', DynamicAttributes::DataType::Text, 'My life in one line')
    ]
  end

end