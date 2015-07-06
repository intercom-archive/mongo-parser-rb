module MongoParserRB
  class Field

    def initialize(field)
      @field = field
      @field_parts = field.to_s.split('.')
    end

    def value_in_document(document)
      @field_parts.reduce(document) do |value, field|
        case value
        when Array
          return [] if value.empty?
          value[field.to_i]
        when Hash
          value[field]
        end
      end
    rescue NoMethodError
      nil
    end

    def in_document?(document)
      @field_parts.reduce(document) do |value, field|
        return false unless value.has_key?(field)
        value[field]
      end

      true
    end

  end
end
