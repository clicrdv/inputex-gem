require 'test/unit'

if RUBY_VERSION >= "1.9.2"
	require 'coveralls'
	Coveralls.wear!
end

require 'inputex'
require File.expand_path '../active_record/connection_adapters/fake_adapter.rb', __FILE__
require 'active_record' 


class Toto < ActiveRecord::Base
end

class TestModel < ActiveRecord::Base
	attr_accessor :not_persisted

	belongs_to :toto

	belongs_to :tata, { :class_name =>'toto', :foreign_key =>"parent_id" }

	validates :status, :inclusion =>{ :in =>["client", "test"] }
end	

class TestInputex < Test::Unit::TestCase

	def setup
		ActiveRecord::Base.establish_connection(:adapter => 'fake')
		ActiveRecord::Base.connection.merge_column('test_models', :email, :string)
		ActiveRecord::Base.connection.merge_column('test_models', :toto_id, :integer)
		ActiveRecord::Base.connection.merge_column('test_models', :parent_id, :integer)
		ActiveRecord::Base.connection.merge_column('test_models', :status, :string, { :default =>"test"})
	end

	def test_id
		fields = TestModel.inputex_fields_definition(["id"])
		assert_equal "hidden", fields.first[:type]
	end

	def test_email
		fields = TestModel.inputex_fields_definition(["email"])
		assert_equal "email", fields.first[:type]
	end

	def test_attr_accessor
		fields = TestModel.inputex_fields_definition(["not_persisted"])
		assert_equal "not_persisted", fields.first[:name]
	end

	def test_belongs_to
		fields = TestModel.inputex_fields_definition(["toto_id", "parent_id"])
		assert_equal "toto_id", fields.first[:type]
		assert_equal "toto_id", fields.last[:type]
	end

	def test_select_field
		fields = TestModel.inputex_fields_definition(["status"])
		assert_equal "select", fields.first[:type]
		assert_equal ["client", "test"], fields.first[:choices]
	end

	def test_default_value
		fields = TestModel.inputex_fields_definition(["status"])
		assert_equal "test", fields.first[:value]
	end

end
