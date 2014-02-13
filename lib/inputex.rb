# Inputex
# =======
# 
# Helpers to generate inputEx forms from ActiveRecord models.
# 
# 
#   * fields named "id" are hidden
#   * "created_at", "updated_at" are uneditable
#   * "email", "url", "password", "colorref", "ip" are rendered using the corresponding inputEx field
# 
#   * columns finishing by "_id" are rendered with their own type, corresponding to the REFLECTION CLASS
#     Ex:
#         A class with a "owner_id" column, and this in the model:
#           belongs_to :owner, :class_name => "Group"
#         
#         => the generated type will be "group_id" (and not "owner_id")
# 
#   * renders datetime, boolean, text, integers, ...
# 
#   * renders select according to the ActiveModel validations
#   
#       validates_inclusion_of :format, :in => ["json", "xml", "urlencoded"]
#         OR
#       validates :format, :inclusion => { :in => ["json", "xml", "urlencoded"] }
#   
# 
# Usage
# =====
# 
#  * I18n MUST be configured.
#    The plugin will look for the key "activerecord.attributes.#{self.name.downcase}.#{column.name}"
# 
#     # Get all fields (The order is generally wrong)
#     MyModel.inputex_fields_definition
# 
#     # Get the fields "id" and "method" (in the same order)
#     MyModel.inputex_fields_definition(["id","method"])
# 
#     # Get a definition given a column
#     MyModel.inputex_field_definition(column, force_uneditable = false)
# 
#     # Get a definition given a column name
#     MyModel.inputex_field_byname(columnName, force_uneditable = false)
#   
# 
# Copyright (c) 2010-2013 ClicRDV

require 'active_support'

module Inputex
  module ModelExtensions
    
    class FakeColumn
      attr_accessor :name
      attr_accessor :sql_type
      attr_accessor :default
    end
    
    extend ::ActiveSupport::Concern
    
    # "extend ClassMethods" is automatically executed at module's inclusion (thanks to ActiveSupport::Concern)
    module ClassMethods
      
      # Return a list of inputEx definitions for the given column names
      def inputex_fields_definition(columnNames = self.columns_hash.keys)
        columnNames.map { |c|
          inputex_field_byname(c)
        }
      end
      
      # Return the inputEx definition from a column name
      def inputex_field_byname(columnName, force_uneditable = false)
        column = self.columns_hash[columnName]
        
        # Support for attribute accessors
        if column.nil?
          column = FakeColumn.new
          column.name = columnName
        end
        
        inputex_field_definition(column, force_uneditable)
      end
      
      # Generate an inputEx definition from the column object
      def inputex_field_definition(column, force_uneditable = false)
        
        field = {
          :type => "string",
          :label => (I18n.t "activerecord.attributes.#{self.name.underscore}.#{column.name}").capitalize,
          :name => column.name,
          :showMsg => true
        }
        
        # Field type
        # TODO: utiliser les types rails
        if force_uneditable
          field[:type] = "uneditable"
          
        elsif column.name == "created_at" || column.name == "updated_at"
          field[:type] = "uneditable"
          
        elsif column.name == "id"
          field[:type] = "hidden"
          
        elsif column.name == "email"
          field[:type] = "email"
          
        elsif column.name == "password" || column.name == "hashed_password"
          field[:type] = "password"
          
        elsif column.name == "colorref"
          field[:type] = "color"
          
        elsif column.name == "ip"
          field[:type] = "IPv4"
          
        elsif column.name == "url"
          field[:type] = "url"
          
        elsif column.name[-3..-1] == "_id" # Autocompleters for liaisons
          # The name of the attribute might be different than the name of the class
          # (ex: Leaf.parent_id refering to another Leaf, the inputEx type is still "leaf_id")
          liaisonName = (column.name[0..-4]).to_sym
          reflection = self.reflections[ liaisonName.to_sym ]
          if reflection
            field[:type] = reflection.klass.to_s.downcase+"_id"
          else
            field[:type] = column.name
          end
          
        elsif column.sql_type == "datetime"
          field[:type] = "datetime"
          
        elsif column.sql_type == "tinyint(1)"
          field[:type] =  "boolean"
          
        elsif column.sql_type == "int(11)"
          field[:type] = "integer"
          
        elsif column.sql_type == "text"
          field[:type] = "text"
          field[:rows] = 6
          field[:cols] = 70
          
        else
          
          # test presence of an InclusionValidator
          inclusion_validators = self.validators_on(column.name).select { |validator|
            validator.is_a?(ActiveModel::Validations::InclusionValidator)
          }
          
          if inclusion_validators.size > 0
            field[:type]    = "select"
            field[:choices] = inclusion_validators[0].send(:delimiter) # use send cause delimiter is private
          end
           
        end
        
        # Default value
        if !column.default.nil?
          field[:value] = column.default
        end
        
        # Required ?
        #if !column.null
        #  field[:required] = true
        #end
        
        field
        
      end
      
    end
    
  end
end

ActiveSupport.on_load(:active_record) do
  include Inputex::ModelExtensions
end
