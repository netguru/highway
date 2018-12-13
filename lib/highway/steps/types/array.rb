#
# array.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Types

      # This class represents an array parameter type.
      class Array

        public

        # Initialize an instance.
        #
        # @param element_type [Object] Type of inner elements.
        def initialize(element_type:)
          @element_type = element_type
        end

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Array<Object>, nil]
        def coerce_and_validate(value:)
          case value
            when ::Array
              coerced = value.map { |element| @element_type.coerce_and_validate(value: element) }
              coerced if coerced.all? { |element| !element.nil? }
            when ::String, ::Numeric, ::TrueClass, ::FalseClass
              coerced = @element_type.coerce_and_validate(value: value)
              [coerced] if coerced != nil
          end
        end

      end

    end
  end
end
