module MongoParserRB
  class Query
    class Expression

      INVERSION_OPERATORS = [:$not].freeze
      CONJUNCTION_OPERATORS = [:$and, :$or].freeze
      NEGATIVE_EQUALITY_OPERATORS = [:$nin, :$ne].freeze
      EQUALITY_OPERATORS = [:$eq, :$gt, :$lt, :$gte, :$lte, :$in, :$nin, :$ne].freeze
      ELEM_MATCH_OPERATORS = [:$elemMatch].freeze

      class << self

        def inversion_operator?(operator)
          INVERSION_OPERATORS.include?(operator)
        end

        def conjunction_operator?(operator)
          CONJUNCTION_OPERATORS.include?(operator)
        end

        def elemMatch_operator?(operator)
          ELEM_MATCH_OPERATORS.include?(operator)
        end

        def operator?(operator)
          EQUALITY_OPERATORS.include?(operator) || conjunction_operator?(operator) || inversion_operator?(operator) || elemMatch_operator?(operator)
        end

      end

      def initialize(operator, *args)
        @operator = operator

        if Expression.conjunction_operator?(@operator)
          @arguments = args[0]
        else
          @field = Field.new(args[0])
          @arguments = args[1]
        end
      end

      def evaluate(document)
        case @operator
        when *Expression::CONJUNCTION_OPERATORS
          evaluate_conjunction(document)
        when *Expression::NEGATIVE_EQUALITY_OPERATORS
          evaluate_negative_equality(document)
        when *Expression::EQUALITY_OPERATORS
          evaluate_equality(document)
        when *Expression::INVERSION_OPERATORS
          evaluate_inversion(document)
        when *Expression::ELEM_MATCH_OPERATORS
          evaluate_elemMatch(document)
        end
      rescue NoMethodError, TypeError
        false
      end

      private

      def evaluate_elemMatch(document)
        @field.value_in_document(document).any? do |subdocument|
          @arguments.all? do |arg|
            arg.evaluate(subdocument)
          end
        end
      end

      def evaluate_inversion(document)
        # Mongo negative equality operators return true when
        # the specified field does not exist on a document.
        return true if !@field.value_in_document(document) && !@field.in_document?(document)
        !@arguments.evaluate(document)
      end

      def evaluate_conjunction(document)
        case @operator
        when :$and
          @arguments.all? do |arg|
            arg.evaluate(document)
          end
        when :$or
          @arguments.any? do |arg|
            arg.evaluate(document)
          end
        end
      end

      def evaluate_negative_equality(document)
        value_for_field = @field.value_in_document(document)

        case @operator
        when :$ne
          # Mongo negative equality operators return true when
          # the specified field does not exist on a document.
          return true if !value_for_field && !@field.in_document?(document)

          if value_for_field.kind_of?(Array) &&
             !@arguments.kind_of?(Array)
            !value_for_field.include?(@arguments)
          else
            value_for_field != @arguments
          end
        when :$nin
          if value_for_field.kind_of?(Array)
            (value_for_field & @arguments).length.zero?
          else
            !@arguments.include?(value_for_field)
          end
        end
      end

      def evaluate_equality(document)
        value_for_field = @field.value_in_document(document)

        case @operator
        when :$eq
          # return true if value_for_field == @argument
          if @arguments.kind_of?(Regexp)
            !!(value_for_field =~ @arguments)
          elsif value_for_field.kind_of?(Array) &&
                !@arguments.kind_of?(Array)
            value_for_field.include?(@arguments)
          else
            value_for_field == @arguments
          end
        when :$gt
          value_for_field > @arguments
        when :$gte
          value_for_field >= @arguments
        when :$lt
          value_for_field < @arguments
        when :$lte
          value_for_field <= @arguments
        when :$in
          if value_for_field.kind_of?(Array)
            (value_for_field & @arguments).length > 0
          else
            @arguments.include?(value_for_field)
          end
        end
      rescue ArgumentError
        false
      end
    end
  end
end
