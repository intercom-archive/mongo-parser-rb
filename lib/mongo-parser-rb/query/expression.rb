module MongoParserRB
  class Query
    class Expression

      class << self

        def conjunction_operators
          @conjunction_operators ||= [
            :$and,
            :$or
          ]
        end

        def conjunction_operator?(operator)
          conjunction_operators.include?(operator)
        end

        def negative_equality_operators
          @negative_equality_operators ||= [
            :$nin,
            :$ne
          ]
        end

        def equality_operators
          @equality_operators ||= [
            :$eq,
            :$gt,
            :$lt,
            :$gte,
            :$lte,
            :$in
          ] | negative_equality_operators
        end

        def equality_operator?(operator)
          equality_operators.include?(operator)
        end

        def operator?(operator)
          equality_operator?(operator) || conjunction_operator?(operator)
        end

      end

      def initialize(operator, *args)
        @operator = operator

        if Expression.conjunction_operator? @operator
          @arguments = args[0]
        else
          @field = Field.new(args[0])
          @arguments = args[1]
        end
      end

      def evaluate(document)
        case @operator
        when *Expression.conjunction_operators
          evaluate_conjunction(document)
        when *Expression.negative_equality_operators
          evaluate_negative_equality(document)
        when *Expression.equality_operators
          evaluate_equality(document)
        end
      rescue NoMethodError, TypeError
        false
      end

      private

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
