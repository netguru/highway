#
# array.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents an array parameter type.
      class Array < Types::Any

        public

        # Initialize an instance.
        #
        # @param element_type [Object] Type of inner elements.
        # @param validate [Proc] A custom value validation block.
        def initialize(element_type, validate: nil)
          super(validate: validate)
          @element_type = element_type
        end

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Array, nil]
        def typecheck(value)
          return nil unless value.kind_of?(::Array)
          typechecked = value.map { |element| @element_type.typecheck_and_validate(element) }
          typechecked if typechecked.all? { |element| !element.nil? }
        end

      end

    end
  end
end
