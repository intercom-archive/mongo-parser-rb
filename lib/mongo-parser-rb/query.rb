module MongoParserRB
  class Query

    def self.parse(raw_query)
      new(raw_query).parse!
    end

    def initialize(raw_query)
      @raw_query = raw_query
    end

    def parse!
      @expression_tree = parse_root_expression(@raw_query)
      self
    end

    def matches_document?(document)
      raise NotParsedError, "Query not parsed (run parse!)" if @expression_tree.nil?
      @expression_tree.evaluate(document)
    end
    
    private

    def parse_root_expression(query, field = nil)
      Expression.new(:$and, query.to_a.map do |(key, value)|
        parse_sub_expression(key, value, field)
      end)
    end
    
    def parse_sub_expression(key, value, field = nil)
      if Expression.operator?(key)
        case key 
        when *Expression.conjunction_operators
          Expression.new(key, value.map { |v| parse_root_expression(v) })
        else
          Expression.new(key, field, value)
        end
      elsif value.kind_of?(Hash)
        parse_root_expression(value, key)
      else
        Expression.new(:$eq, key, value)
      end
    end

  end
end
