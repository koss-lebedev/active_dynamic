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

  CreateActiveDynamicAttributesTable.migrate :up

end

class Profile < ActiveRecord::Base
  has_dynamic_attributes
  validates :first_name, presence: true
end

class ProfileAttributeProvider

  def initialize(model); end

  def call
    [
      ActiveDynamic::AttributeDefinition.new('Life Story',
        ActiveDynamic::DataType::Text,
        'default value for story',
        true),
      ActiveDynamic::AttributeDefinition.new('Age',
        ActiveDynamic::DataType::Integer,
        'value for age',
        false),
      ActiveDynamic::AttributeDefinition.new('Please, tell us what is your home town',
        ActiveDynamic::DataType::String,
        nil,
        false,
        system_name: 'Home Town'
        )
    ]
  end

end
