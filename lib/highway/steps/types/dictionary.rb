#
# dictionary.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"
require "highway/utilities"

module Highway
  module Steps
    module Types

      # This class represents a dictionary parameter type.
      class Dictionary < Types::Any

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
        # @return [Hash, nil]
        def typecheck(value)
          return nil unless value.is_a?(::Hash)
          typechecked = Utilities::hash_map(value) { |key, element| [key, @element_type.typecheck_and_validate(element)] }
          typechecked if typechecked.values.all? { |element| !element.nil? }
        end

      end

    end
  end
end
