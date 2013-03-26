module MongoParserRB
  class Field

    def initialize(field)
      @field = field
      @field_parts = field.to_s.split('.')
    end

    def value_in_document(document)
      document = stringify_keys(document)
      @field_parts.reduce(document) do |value, field|
        value[field]
      end
    rescue NoMethodError
      nil
    end

    def in_document?(document)
      document = stringify_keys(document)

      @field_parts.reduce(document) do |value, field|
        return false unless value.has_key?(field)
        value[field]
      end

      true
    end

    private

    def stringify_keys(document)
      document.reduce({}) do |new_document, (k,v)|
        new_document[k.to_s] = v.kind_of?(Hash) ? stringify_keys(v) : v
        new_document
      end
    end

  end
end
