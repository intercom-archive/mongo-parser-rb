module MongoParserRB
  class Query

    # Parse a query, returning an initialized MongoParserRB::Query object.
    #
    # @param raw_query [Hash] the hash to parse
    # @return [MongoParserRB::Query] initialized query object
    def self.parse(raw_query)
      new(raw_query).parse!
    end

    # Use {MongoParserRB::Query.parse}.
    # @visibility private
    def initialize(raw_query)
      @raw_query = raw_query
    end

    # @visibility private
    def parse!
      @expression_tree = parse_root_expression(@raw_query)
      self
    end

    # Check if a document matches a query.
    #
    #     q = MongoParserRB::Query.parse(:x => {:$gt => 3})
    #     q.matches_document?(:x => 4) => true
    #     q.matches_document?(:x => 3) => false
    #
    # @param document [Hash] The document to check
    # @return [Boolean]
    def matches_document?(document)
      raise NotParsedError, "Query not parsed (run parse!)" if @expression_tree.nil?

      document = stringify_keys(document)
      @expression_tree.evaluate(document)
    end

    private

    def parse_root_expression(query, field = nil)
      Expression.new(:$and, query.to_a.map do |(key, value)|
        parse_sub_expression(key, value, field)
      end)
    end

    def parse_sub_expression(key, value, field = nil)
      if Expression::ALL_OPERATORS.include?(key)
        case key
        when *Expression::CONJUNCTION_OPERATORS
          Expression.new(key, value.map { |v| parse_root_expression(v) })
        when *Expression::INVERSION_OPERATORS
          if value.kind_of?(Hash)
            Expression.new(:$not, field, parse_root_expression(value, field))
          else
            Expression.new(:$not, field, Expression.new(:$eq, field, value))
          end
        when *Expression::ELEM_MATCH_OPERATORS
          Expression.new(:$elemMatch, field, value.to_a.map do |(key, value)|
            parse_sub_expression(key, value)
          end)
        else
          Expression.new(key, field, value)
        end
      elsif value.kind_of?(Hash)
        parse_root_expression(value, key)
      else
        Expression.new(:$eq, key, value)
      end
    end

    def stringify_keys(document)
      document.reduce({}) do |new_document, (k,v)|
        new_document[k.to_s] = case v
        when Hash
          stringify_keys(v)
        when Array
          v.map { |e| e.kind_of?(Hash) ? stringify_keys(e) : e }
        else
          v
        end

        new_document
      end
    end

  end
end
