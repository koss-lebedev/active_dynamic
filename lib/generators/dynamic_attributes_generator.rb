require 'rails/generators'
require 'rails/generators/active_record'

class DynamicAttributesGenerator < ActiveRecord::Generators::Base

  # ActiveRecord::Generators::Base inherits from Rails::Generators::NamedBase which requires a NAME parameter for the
  # new table name. Our generator always uses 'dynamic_attributes', so default value is irrelevant
  argument :name, type: :string, default: 'dummy'

  class_option :'skip-migration', type: :boolean, desc: "Don't generate a migration for the dynamic attributes table"

  source_root File.expand_path('../../dynamic_attributes', __FILE__)

  def copy_files
    return if options['skip-migration']
    migration_template 'migration.rb', 'db/migrate/create_dynamic_attributes_table.rb'
  end

end