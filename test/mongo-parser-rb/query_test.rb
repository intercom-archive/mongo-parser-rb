require 'test_helper'

class QueryTest < MiniTest::Unit::TestCase

  def test_raises_if_not_parsed
    assert_raises(MongoParserRB::NotParsedError) do
      query = MongoParserRB::Query.new(:integer_key => 10)
      query.matches_document?({})
    end
  end

  def test_integer_eq
    query = MongoParserRB::Query.parse(:integer_key => 10)
    assert query.matches_document?(:integer_key => 10)
    refute query.matches_document?(:integer_key => 9)
  end

  def test_integer_ne
    query = MongoParserRB::Query.parse(:integer_key => {:$ne => 10})
    assert query.matches_document?(:integer_key => 9)
    refute query.matches_document?(:integer_key => 10)
  end

  def test_integer_gt
    query = MongoParserRB::Query.parse(:integer_key => {:$gt => 10})
    assert query.matches_document?(:integer_key => 11)
    refute query.matches_document?(:integer_key => 10)
    refute query.matches_document?(:integer_key => 9)
  end

  def test_integer_lt
    query = MongoParserRB::Query.parse(:integer_key => {:$lt => 10})
    query.matches_document?(:integer_key => 9)
    query.matches_document?(:integer_key => 10)
    query.matches_document?(:integer_key => 11)
  end

  def test_integer_lte
    query = MongoParserRB::Query.parse(:integer_key => {:$lte => 10})
    assert query.matches_document?(:integer_key => 9)
    assert query.matches_document?(:integer_key => 10)
    refute query.matches_document?(:integer_key => 11)
  end

 def test_integer_gte
    query = MongoParserRB::Query.parse(:integer_key => {:$lte => 10})
    assert query.matches_document?(:integer_key => 9)
    assert query.matches_document?(:integer_key => 10)
    refute query.matches_document?(:integer_key => 11)
  end

  def test_integer_lte_and_integer_gt
    query = MongoParserRB::Query.parse(:integer_key => {:$lte => 10}, :integer_key_2 => {:$gt => 5})
    assert query.matches_document?(:integer_key => 9, :integer_key_2 => 6)
    refute query.matches_document?(:integer_key => 9, :integer_key_2 => 4)
    refute query.matches_document?(:integer_key => 11, :integer_key_2 => 4)
  end

  def test_string_eq
    query = MongoParserRB::Query.parse(:string_key => "hello world")
    assert query.matches_document?(:string_key => "hello world")
    refute query.matches_document?(:string_key => 1)
    refute query.matches_document?(:string_key => "bye world")
  end

  def test_string_gt
    query = MongoParserRB::Query.parse(:string_key => {:$gt => 'abc'})
    assert query.matches_document?(:string_key => "abcd")
    assert query.matches_document?(:string_key => "e")
    refute query.matches_document?(:string_key => "abc")
  end

  def test_string_lt
    query = MongoParserRB::Query.parse(:string_key => {:$lt => 'm'})
    assert query.matches_document?(:string_key => "abc")
    refute query.matches_document?(:string_key => "xyz")
  end

  def test_string_and_integer_equality
    query = MongoParserRB::Query.parse(:string_key => {:$lt => 'm'}, :integer_key => {:$gt => 4})
    assert query.matches_document?(:string_key => "abc", :integer_key => 5)
    refute query.matches_document?(:string_key => "xyz", :integer_key => 5)
    refute query.matches_document?(:string_key => "abc", :integer_key => 4)
  end


  def test_or
    query = MongoParserRB::Query.parse(:$or => [
      {:string_key => "abc"},
      {:integer_key => {:$gt => 5}}
    ])

    assert query.matches_document?(:string_key => "abc")
    refute query.matches_document?(:string_key => "cde")
    assert query.matches_document?(:string_key => "cde", :integer_key => 6)
    assert query.matches_document?(:string_key => "abc", :integer_key => 6)
    assert query.matches_document?(:integer_key => 6)
    refute query.matches_document?(:integer_key => 5)
  end

  def test_boolean_eq
    query = MongoParserRB::Query.parse(:boolean_key => false)
    assert query.matches_document?(:boolean_key => false)
    refute query.matches_document?(:boolean_key => true)
  end

  def test_query_field_integration
    query = MongoParserRB::Query.parse(:"custom_data.tracked_users" => {:$gt => 3})
    assert query.matches_document?(:custom_data => {:tracked_users => 10})
    refute query.matches_document?(:custom_data => {:tracked_users => 1})
  end

  def test_array_in
    query = MongoParserRB::Query.parse(:array_key => {:$in => [1]})
    assert query.matches_document?(:array_key => [1,2])
    refute query.matches_document?(:array_key => [2,3])
  end

  def test_array_nin
    query = MongoParserRB::Query.parse(:array_key => {:$nin => [1,2]})
    assert query.matches_document?(:array_key => [3,4,5])
    refute query.matches_document?(:array_key => [1,4,5])
  end

  def test_nil_by_absence_nin 
    query = MongoParserRB::Query.parse(:"custom_data.value" => {:$nin => [nil]})
    assert query.matches_document?(:custom_data => {:value => 5})
    refute query.matches_document?({})
  end

  def test_integer_in
    query = MongoParserRB::Query.parse(:integer_key => {:$in => [1,2]})
    assert query.matches_document?(:integer_key => 1)
    assert query.matches_document?(:integer_key => 2)
    refute query.matches_document?(:integer_key => 3)
  end

  def test_eq_nil
    query = MongoParserRB::Query.parse(:string_key => nil)
    assert query.matches_document?(:string_key => nil)
    refute query.matches_document?(:string_key => 'hey')
    assert query.matches_document?(:something_else => "hello")
    assert query.matches_document?({})
  end

  def test_ne_with_nil
    query = MongoParserRB::Query.parse(:string_key => {:$ne => 'cheese'})
    assert query.matches_document?(:string_key => nil)
    assert query.matches_document?({})
  end

  def test_no_key_in_unknown
    query = MongoParserRB::Query.parse(:string_key => {:$in=>[nil, "", "null", "nil"]})
    assert query.matches_document?(:something_else => "hello")
  end

  def test_regex_eq
    query = MongoParserRB::Query.parse(:string_key => /hello/)
    assert query.matches_document?(:string_key => 'hello world')
    refute query.matches_document?(:string_key => 'world')
  end

  def test_string_regex
    query = MongoParserRB::Query.parse(:string_key => {:$regex=>'hello'})
    assert query.matches_document?(:string_key => 'hello world')
    refute query.matches_document?(:string_key => 'world')
  end


  def test_operator_data_type_mismatch
    query = MongoParserRB::Query.parse(:array_key => {:$in => [1]})
    refute query.matches_document?(:array_key => "hey")
  end

  def test_date_range
    query = MongoParserRB::Query.parse(:date_key => {:$gt => Time.new(1993,2,13,0,0,0)})
    assert query.matches_document?(:date_key => Time.new(1994,2,13,0,0,0))
    refute query.matches_document?(:date_key => Time.new(1992,2,13,0,0,0))

    query = MongoParserRB::Query.parse(:date_key => {:$gt => Time.new(1993,2,13,0,0,0), :$lt => Time.new(1995,2,13,0,0,0)})
    assert query.matches_document?(:date_key => Time.new(1994,2,13,0,0,0))
    refute query.matches_document?(:date_key => Time.new(1996,2,13,0,0,0))
  end

  def test_eq_as_in_substitute
    query = MongoParserRB::Query.parse(:array_key => 1)
    assert query.matches_document?(:array_key => [1,2])

    query = MongoParserRB::Query.parse(:array_key => [1])
    refute query.matches_document?(:array_key => [1,2])
  end

  def test_ne_as_nin_substitue
    query = MongoParserRB::Query.parse(:array_key => {:$ne => 1})
    assert query.matches_document?(:array_key => [2,3])

    query = MongoParserRB::Query.parse(:array_key => {:$ne => [1]})
    assert query.matches_document?(:array_key => [1,2])
  end

  def test_datatype_mismatch
    query = MongoParserRB::Query.parse(:integer_key => {:$gt => 5})
    refute query.matches_document?(:integer_key => "hello")
  end
    
end
