require 'test_helper'

class FieldTest < MiniTest::Unit::TestCase

  def test_returns_value_when_key_present
    field = MongoParserRB::Field.new(:"custom_data.tracked_users")
    assert_equal 10, field.value_in_document(:custom_data => {:tracked_users => 10})
  end

  def test_returns_nil_when_key_not_present
    field = MongoParserRB::Field.new(:"custom_data.tracked_users")
    assert_nil field.value_in_document(:custom_data => {:something_else => 10})
    assert_nil field.value_in_document(:name => "Ben")
  end

  def test_document_has_a_field
    field = MongoParserRB::Field.new(:"custom_data.tracked_users")
    assert field.in_document?(:custom_data => {:tracked_users => 10})
    refute field.in_document?(:not_custom_data => {:tracked_users => 10})

    field = MongoParserRB::Field.new(:"session_count")
    assert field.in_document?(:custom_data => {:tracked_users => 10}, :session_count => 5)
    refute field.in_document?(:custom_data => {:tracked_users => 10})
  end

  def test_returning_array_element
    field = MongoParserRB::Field.new(:"something.array.0")
    assert_equal 1, field.value_in_document(:something => {:array => [1,2]})
  end

  def test_returning_hash_in_array
    field = MongoParserRB::Field.new(:"something.array.0.key")
    document = {:something => {:array => [{:key => 'hello world'}, {:key => 'bye world'}]}}
    assert_equal 'hello world', field.value_in_document(document)

    field = MongoParserRB::Field.new(:"something.array.1.key")
    assert_equal 'bye world', field.value_in_document(document)
  end

end
