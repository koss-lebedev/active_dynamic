require 'rails/generators'
require 'rails/generators/active_record'

class ActiveDynamicGenerator < ActiveRecord::Generators::Base

  # ActiveRecord::Generators::Base inherits from Rails::Generators::NamedBase which requires a NAME parameter for the
  # new table name. Our generator always uses 'active_dynamic_attributes', so default value is irrelevant
  argument :name, type: :string, default: 'dummy'

  class_option :'skip-migration', type: :boolean, desc: "Don't generate a migration for the dynamic attributes table"

  source_root File.expand_path('../../active_dynamic', __FILE__)

  def copy_files
    return if options['skip-migration']
    migration_template 'migration.rb', 'db/migrate/create_active_dynamic_attributes_table.rb'
  end

end