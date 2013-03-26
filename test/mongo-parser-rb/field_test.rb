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

end
